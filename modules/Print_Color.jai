// A small wrapper around OS console color commands / escape codes.

// USE_ANSI_CODES_ON_WINDOWS:
// Windows now recommends using ANSI escape codes instead of SetConsoleTextAttribute (see https://learn.microsoft.com/en-us/windows/console/classic-vs-vt).
// But that didn't work in my tests on Win 10 Pro’s cmd.exe, so we fall back to the old API for now:
// SAVE_RESTORE_ON_WINDOWS:
// Whether to save/restore the previous color on Windows or just reset to the default color.
// The former seems light The Right Thing to do because it respects whatever the user set as default color, but it introduces a race condition if multiple threads print in color.
#module_parameters () (USE_ANSI_CODES_ON_WINDOWS := false, SAVE_RESTORE_ON_WINDOWS := false);

print_color :: (format_string: string, args: .. Any, color: Console_Color, style: Console_Style = .NORMAL, to_standard_error := false) {
    with_console_color(color, print(format_string, ..args, to_standard_error = to_standard_error), style = style, to_standard_error = to_standard_error);
}

Console_Color :: enum_flags u16 {
    BLACK         :: 30;
    RED           :: 31;
    GREEN         :: 32;
    BLUE          :: 34;
    CYAN          :: 36;
    MAGENTA       :: 35;
    YELLOW        :: 33;
    WHITE         :: 37;

    HI_BLACK      :: 90;
    HI_RED        :: 91;
    HI_GREEN      :: 92;
    HI_BLUE       :: 94;
    HI_CYAN       :: 96;
    HI_MAGENTA    :: 95;
    HI_YELLOW     :: 93;
    HI_WHITE      :: 97;

    BG_BLACK      :: 40;
    BG_RED        :: 41;
    BG_GREEN      :: 42;
    BG_BLUE       :: 44;
    BG_CYAN       :: 46;
    BG_MAGENTA    :: 45;
    BG_YELLOW     :: 43;
    BG_WHITE      :: 47;

    BG_HI_BLACK   :: 100;
    BG_HI_RED     :: 101;
    BG_HI_GREEN   :: 102;
    BG_HI_BLUE    :: 104;
    BG_HI_CYAN    :: 106;
    BG_HI_MAGENTA :: 105;
    BG_HI_YELLOW  :: 103;
    BG_HI_WHITE   :: 107;
}

Console_Style :: enum {
    NORMAL    :: 0;
    BOLD      :: 1;
    UNDERLINE :: 4;
}

#if OS != .WINDOWS {
    // Sets the console color and resets it after executing "code";
    with_console_color :: (color: Console_Color, code: Code, style: Console_Style = .NORMAL, to_standard_error := false) #expand {
        set_console_color(color, style = style, to_standard_error = to_standard_error);
        #insert code;
        reset_console_color(to_standard_error);
    }

    // Checks if it is a tty on set_console_color() as well as reset_console_color(),
    // mostly because they need to work independently.
    // I think it is also possible for the output to change inbetween set and reset.
    // -Stvff
    set_console_color :: (color: Console_Color, style: Console_Style = .NORMAL, to_standard_error := false) {
        handle := ifx to_standard_error then STDERR_FILENO else STDOUT_FILENO;
        if isatty(xx handle) print("\e[%;%m", cast(int) style, cast(int) color, to_standard_error = to_standard_error);
    }

    reset_console_color :: (to_standard_error := false) {
        handle := ifx to_standard_error then STDERR_FILENO else STDOUT_FILENO;
        if isatty(xx handle) write_string("\e[0;m", to_standard_error = to_standard_error);
    }

    #import "POSIX";
} else #if USE_ANSI_CODES_ON_WINDOWS {
    // Sets the console color and resets it after executing "code";
    with_console_color :: (color: Console_Color, code: Code, style: Console_Style = .NORMAL, to_standard_error := false) #expand {
        set_console_color(color, style = style, to_standard_error = to_standard_error);
        #insert code;
        reset_console_color(to_standard_error);
    }

    // We should be checking for if this is a tty on windows, and as possible candidates I've found:
    //   GetFileType()
    //   GetConsoleScreenBufferInfo()
    // But that last one I'm not sure about yet.
    // - Stvff
    set_console_color :: (color: Console_Color, style: Console_Style = .NORMAL, to_standard_error := false) {
        print("\e[%;%m", cast(int) style, cast(int) color, to_standard_error = to_standard_error);
    }

    reset_console_color :: (to_standard_error := false) {
        write_string("\e[0;m", to_standard_error = to_standard_error);
    }
} else {

    with_console_color :: (color: Console_Color, code: Code, style: Console_Style = .NORMAL /* ignored_on Windows */, to_standard_error := false /* ignored_on Windows */) #expand {
        hConsole: HANDLE = GetStdHandle(STD_OUTPUT_HANDLE);

        #if SAVE_RESTORE_ON_WINDOWS {
            // Save current attributes
            consoleInfo: CONSOLE_SCREEN_BUFFER_INFO;
            GetConsoleScreenBufferInfo(hConsole, *consoleInfo);
            saved_attributes := consoleInfo.wAttributes;
        }

        RED               :: 0x0004;
        GREEN             :: 0x0002;
        BLUE              :: 0x0001;
        HIGH_INTENSITY    :: 0x0008;
        BG_BLUE           :: 0x0010;
        BG_GREEN          :: 0x0020;
        BG_RED            :: 0x0040;
        BG_HIGH_INTENSITY :: 0x0080;
        win_color: u16;

        if #complete color == {
            case .BLACK; win_color = BG_RED | BG_GREEN | BG_BLUE;
            case .RED; win_color = RED;
            case .GREEN; win_color = GREEN;
            case .BLUE; win_color = BLUE;
            case .CYAN; win_color = GREEN | BLUE;
            case .MAGENTA; win_color = RED | BLUE;
            case .YELLOW; win_color = RED | GREEN;
            case .WHITE; win_color = RED | GREEN | BLUE;

            case .HI_BLACK; win_color = RED | GREEN | BLUE | HIGH_INTENSITY; // Same as HI_WHITE for now
            case .HI_RED; win_color = RED | HIGH_INTENSITY;
            case .HI_GREEN; win_color = GREEN | HIGH_INTENSITY;
            case .HI_BLUE; win_color = BLUE | HIGH_INTENSITY;
            case .HI_CYAN; win_color = GREEN | BLUE | HIGH_INTENSITY;
            case .HI_MAGENTA; win_color = RED | BLUE | HIGH_INTENSITY;
            case .HI_YELLOW; win_color = RED | GREEN | HIGH_INTENSITY;
            case .HI_WHITE; win_color = RED | GREEN | BLUE | HIGH_INTENSITY;

            case .BG_BLACK; win_color = RED | GREEN | BLUE;
            case .BG_RED; win_color = BG_RED;
            case .BG_GREEN; win_color = BG_GREEN;
            case .BG_BLUE; win_color = BG_BLUE;
            case .BG_CYAN; win_color = BG_GREEN | BG_BLUE;
            case .BG_MAGENTA; win_color = BG_RED | BG_BLUE;
            case .BG_YELLOW; win_color = BG_RED | BG_GREEN;
            case .BG_WHITE; win_color = BG_RED | BG_GREEN | BG_BLUE;

            case .BG_HI_BLACK; win_color = BG_RED | BG_GREEN | BG_BLUE | BG_HIGH_INTENSITY; // Same as BG_HI_WHITE for now
            case .BG_HI_RED; win_color = BG_RED | BG_HIGH_INTENSITY;
            case .BG_HI_GREEN; win_color = BG_GREEN | BG_HIGH_INTENSITY;
            case .BG_HI_BLUE; win_color = BG_BLUE | BG_HIGH_INTENSITY;
            case .BG_HI_CYAN; win_color = BG_GREEN | BG_BLUE | BG_HIGH_INTENSITY;
            case .BG_HI_MAGENTA; win_color = BG_RED | BG_BLUE | BG_HIGH_INTENSITY;
            case .BG_HI_YELLOW; win_color = BG_RED | BG_GREEN | BG_HIGH_INTENSITY;
            case .BG_HI_WHITE; win_color = BG_RED | BG_GREEN | BG_BLUE | BG_HIGH_INTENSITY;
        }

        SetConsoleTextAttribute(hConsole, win_color);
        #insert code;
        #if SAVE_RESTORE_ON_WINDOWS {
            SetConsoleTextAttribute(hConsole, saved_attributes);
        } else {
            SetConsoleTextAttribute(hConsole, RED | GREEN | BLUE);
        }
    }

    #scope_file;

    GetConsoleScreenBufferInfo :: (hConsoleOutput: HANDLE, lpConsoleScreenBufferInfo : *CONSOLE_SCREEN_BUFFER_INFO) -> BOOL #foreign kernel32;
    SetConsoleTextAttribute :: (hConsoleOutput: HANDLE, wAttributes : u16) -> BOOL #foreign kernel32;
    GetStdHandle :: (handle: s32) -> HANDLE #foreign kernel32;

    HANDLE :: *void;

    SMALL_RECT :: struct {
        left, top, right, bottom: s16;
    }

    COORD :: struct {
        x, y: s16;
    }

    CONSOLE_SCREEN_BUFFER_INFO :: struct {
        dwSize, dwCursorPosition: COORD;
        wAttributes: u16;
        srWindow: SMALL_RECT;
        dwMaximumWindowSize: COORD;
    }

    BOOL     :: enum s32 { FALSE :: 0; TRUE :: 1; }

    STD_OUTPUT_HANDLE :: -11;

    kernel32 :: #library,system "kernel32";
}

#scope_file;

#import "Basic";
