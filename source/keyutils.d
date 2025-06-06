module keyutils;
import std.conv;
import std.stdio;

version(OSX){
    extern(C) int* CGEventCreateKeyboardEvent(int* source, ushort key, bool flag);

    extern(C) void CGEventPost(int tap, int*);

    extern(C) void CGEventSetFlags(int*, int);

    extern(C) void CFRelease (int* cf);
}

void downKey(Key key, int flag = 0){
    version(OSX){
        sendKey(key.to!ushort, true, flag);
    }
    version(Windows){
        if(flag == 0){
            sendKey(key.to!ushort, true, 0);
        }else if(flag == 0x00020000){ // shift
            sendKey(Key.Shift.to!ushort, true, 0);
            sendKey(key.to!ushort, true, 0);
            sendKey(Key.Shift.to!ushort, false, 0);
        }else if(flag == 0x00100000){ // ctrl
            sendKey(Key.Control.to!ushort, true, 0);
            sendKey(key.to!ushort, true, 0);
            sendKey(Key.Control.to!ushort, false, 0);
        }else if(flag == 0x00120000){ // ctrl + shift
            sendKey(Key.Control.to!ushort, true, 0);
            sendKey(Key.Shift.to!ushort, true, 0);
            sendKey(key.to!ushort, true, 0);
            sendKey(Key.Shift.to!ushort, false, 0);
            sendKey(Key.Control.to!ushort, false, 0);
        }
    }
}

void upKey(Key key, int flag = 0){
    sendKey(key.to!ushort, false, flag);
}

void sendKey(ushort keycode, bool type, int flag){
    version(OSX){
        auto key = CGEventCreateKeyboardEvent(null, keycode, type);
        CGEventSetFlags(key, flag);
        CGEventPost(0, key);
        CFRelease(key);
    }
    version(Windows){
        import core.sys.windows.windows;

        int KEYEVENTF_KEYDOWN = 0x0;
        int KEYEVENTF_KEYUP = 0x2;
        int KEYEVENTF_EXTENDEDKEY = 0x1;

        KEYBDINPUT keyboardInput;

        keyboardInput.wVk = keycode;
        if(type){
            keyboardInput.dwFlags = KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYDOWN;
        }else{
            keyboardInput.dwFlags = KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP;
        }
        keyboardInput.dwExtraInfo = 0;
        keyboardInput.time = 0;

        INPUT input;
        input.type = 1;
        input.ki = keyboardInput;
        INPUT[] inputs = [input];
        writeln(keycode);
        SendInput(1, inputs.ptr, INPUT.sizeof);
    }
}

version(OSX){
    enum Key{
    A                    = 0x00,
    S                    = 0x01,
    D                    = 0x02,
    F                    = 0x03,
    H                    = 0x04,
    G                    = 0x05,
    Z                    = 0x06,
    X                    = 0x07,
    C                    = 0x08,
    V                    = 0x09,
    B                    = 0x0B,
    Q                    = 0x0C,
    W                    = 0x0D,
    E                    = 0x0E,
    R                    = 0x0F,
    Y                    = 0x10,
    T                    = 0x11,
    Num1                    = 0x12,
    Num2                    = 0x13,
    Num3                    = 0x14,
    Num4                    = 0x15,
    Num6                    = 0x16,
    Num5                    = 0x17,
    Equal                = 0x18,
    Num9                    = 0x19,
    Num7                    = 0x1A,
    Minus                = 0x1B,
    Num8                    = 0x1C,
    Num0                    = 0x1D,
    RightBracket         = 0x1E,
    O                    = 0x1F,
    U                    = 0x20,
    LeftBracket          = 0x21,
    I                    = 0x22,
    P                    = 0x23,
    L                    = 0x25,
    J                    = 0x26,
    Quote                = 0x27,
    K                    = 0x28,
    Semicolon            = 0x29,
    Backslash            = 0x2A,
    Comma                = 0x2B,
    Slash                = 0x2C,
    N                    = 0x2D,
    M                    = 0x2E,
    Period               = 0x2F,
    Grave                = 0x32,
    KeypadDecimal        = 0x41,
    KeypadMultiply       = 0x43,
    KeypadPlus           = 0x45,
    KeypadClear          = 0x47,
    KeypadDivide         = 0x4B,
    KeypadEnter          = 0x4C,
    KeypadMinus          = 0x4E,
    KeypadEquals         = 0x51,
    Keypad0              = 0x52,
    Keypad1              = 0x53,
    Keypad2              = 0x54,
    Keypad3              = 0x55,
    Keypad4              = 0x56,
    Keypad5              = 0x57,
    Keypad6              = 0x58,
    Keypad7              = 0x59,
    Keypad8              = 0x5B,
    Keypad9              = 0x5C,
    Return                    = 0x24,
    Tab                       = 0x30,
    Space                     = 0x31,
    Delete                    = 0x33,
    Escape                    = 0x35,
    Command                   = 0x37,
    Shift                     = 0x38,
    CapsLock                  = 0x39,
    Option                    = 0x3A,
    Control                   = 0x3B,
    RightShift                = 0x3C,
    RightOption               = 0x3D,
    RightControl              = 0x3E,
    Function                  = 0x3F,
    F17                       = 0x40,
    VolumeUp                  = 0x48,
    VolumeDown                = 0x49,
    Mute                      = 0x4A,
    F18                       = 0x4F,
    F19                       = 0x50,
    F20                       = 0x5A,
    F5                        = 0x60,
    F6                        = 0x61,
    F7                        = 0x62,
    F3                        = 0x63,
    F8                        = 0x64,
    F9                        = 0x65,
    F11                       = 0x67,
    F13                       = 0x69,
    F16                       = 0x6A,
    F14                       = 0x6B,
    F10                       = 0x6D,
    F12                       = 0x6F,
    F15                       = 0x71,
    Help                      = 0x72,
    Home                      = 0x73,
    PageUp                    = 0x74,
    ForwardDelete             = 0x75,
    F4                        = 0x76,
    End                       = 0x77,
    F2                        = 0x78,
    PageDown                  = 0x79,
    F1                        = 0x7A,
    LeftArrow                 = 0x7B,
    RightArrow                = 0x7C,
    DownArrow                 = 0x7D,
    UpArrow                   = 0x7E, 
    CloseBracket              = 0x1e, 
    OpenBracket               = 0x21,
    International1            = 0x5e, 
    }
}

version(Windows){
    enum Key{
        Enter = 0x0D,
        Control = 0x11,
        Shift = 0x10,
        OpenBracket = 0xDB,
        CloseBracket = 0xDD,
        Space = 0x20,
        J = 0x4A,
        M = 0x4D,
        P = 0x50,
        F = 0x46,
        G = 0x47,
        Z = 0x5A,
        I = 0x49,
        B = 0x42,
        R = 0x52,
        E = 0x45,
        H = 0x48,
        C = 0x43,
        D = 0x44,
        T = 0x54,
        V = 0x56,
        L = 0x4C,
        W = 0x57,
        Tab = 0x09,
        F5= 0x74,
        F6= 0x75,
        F7= 0x76,
        One = 0x31,
        Two = 0x32,
        Three = 0x33,
        Four = 0x34,
        Five = 0x35,
    }
}
