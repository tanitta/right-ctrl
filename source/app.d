import std.stdio;
import core.thread;
import std.datetime;
import std.range;
import std.conv;
import derelict.sdl2.sdl;
import rx;
import std.container;
import gamepad;
import looprunner;
import std.exception;

version(OSX){
    extern(C) int* CGEventCreateKeyboardEvent(int* source, ushort key, bool flag);

    extern(C) void CGEventPost(int tap, int*);

    extern(C) void CGEventSetFlags(int*, int);

    extern(C) void CFRelease (int* cf);
}

// extern(C) void CFRelease(int*);



void main() {
    DerelictSDL2.load();
    SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS, "1");
    SDL_Init(0);scope(exit)SDL_Quit();
    SDL_InitSubSystem(SDL_INIT_JOYSTICK);

    auto ctrl = new RightCtrl();
    ctrl.searchPad;
    ctrl.setup();
    auto runner = (new LoopRunner()).targetFps(60f)
                                    .run((){ctrl.update();});
}

///
class RightCtrl{
    public{
        SDLGamePad currentPad(){
            return _currentPad;
        }

        void setup(){
            int currentLayer = 0;

            Disposable[] disposableLayer0 = createDisposableLayer0;
            Disposable[] disposableLayer1;
            Disposable[] disposableLayer2;

            _currentPad.onDownButton(Button.R1)
                       .doSubscribe!((_){
                                            if(currentLayer == 0){
                                                disposableLayer0.each!(d => d.dispose());
                                                disposableLayer1 = createDisposableLayer1();
                                                currentLayer = 1;
                                            }
                                        });
            _currentPad.onUpButton(Button.R1)
                       .doSubscribe!((_){
                                            disposableLayer1.each!(d => d.dispose());
                                            currentLayer = 0;
                                            disposableLayer0 = createDisposableLayer0();
                                        });

            _currentPad.onDownButton(Button.R2)
                       .doSubscribe!((_){
                                            if(currentLayer == 0){
                                                disposableLayer0.each!(d => d.dispose());
                                                disposableLayer2 = createDisposableLayer2();
                                                currentLayer = 2;
                                            }
                                        });
            _currentPad.onUpButton(Button.R2)
                       .doSubscribe!((_){
                                            disposableLayer2.each!(d => d.dispose());
                                            currentLayer = 0;
                                            disposableLayer0 = createDisposableLayer0();
                                        });
        }

        auto createDisposableLayer0(){
            Disposable[] disposables;
            disposables ~=
            _currentPad.onDownButton(Button.Y)
                       .doSubscribe!((_){
                                          downKey(Key.Z, 0x00100000);
                                          upKey(Key.Z);
                                      });
            disposables ~=
            _currentPad.onDownButton(Button.B)
                       .doSubscribe((bool b){
                                                downKey(Key.Z, 0x00120000);
                                                upKey(Key.Z);
                                             });
            disposables ~=
            _currentPad.onStayButtonPeriodicly(Button.X)
                       .doSubscribe((bool b){
                                                downKey(Key.CloseBracket);
                                                upKey(Key.CloseBracket);
                                        });
            disposables ~=
            _currentPad.onStayButtonPeriodicly(Button.A)
                       .doSubscribe((bool b){
                                                downKey(Key.OpenBracket);
                                                upKey(Key.OpenBracket);
                                        });

            // toolselect
            disposables ~=
            _currentPad.onDownButton(Button.RightStick)
                       .doSubscribe((bool b){
                                                downKey(Key.I);
                                            })
                       .withDisposed((){
                                           upKey(Key.I);
                                       });
            disposables ~=
            _currentPad.onUpButton(Button.RightStick)
                       .doSubscribe((bool b){
                                                upKey(Key.I);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                downKey(Key.R);
                                        })
                       .withDisposed((){
                                           upKey(Key.R);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                upKey(Key.R);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RDown)
                       .doSubscribe((bool b){
                                                downKey(Key.Z);
                                        })
                       .withDisposed((){
                                           upKey(Key.Z);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RDown)
                       .doSubscribe((bool b){
                                                upKey(Key.Z);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                downKey(Key.E);
                                        })
                       .withDisposed((){
                                           upKey(Key.E);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                upKey(Key.E);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                downKey(Key.H);
                                        })
                       .withDisposed((){
                                           upKey(Key.H);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                upKey(Key.H);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            return disposables;
        }

        auto createDisposableLayer1(){
            Disposable[] disposables;
            disposables ~=
            _currentPad.onDownButton(Button.X)
                       .doSubscribe((bool b){
                                                downKey(Key.C, 0x00100000);
                                                upKey(Key.C);
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.A)
                       .doSubscribe((bool b){
                                                downKey(Key.D, 0x00100000);
                                                upKey(Key.D);
                                            });

            disposables ~=
            _currentPad.onDownButton(Button.Y)
                       .doSubscribe((bool b){
                                                downKey(Key.T, 0x00100000);
                                                upKey(Key.T);
                                            })
                       .withDisposed((){
                                       });

            disposables ~=
            _currentPad.onDownButton(Button.B)
                       .doSubscribe((bool b){
                                                downKey(Key.V, 0x00100000);
                                                upKey(Key.V);
                                            })
                       .withDisposed((){
                                       });


            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                downKey(Key.L);
                                        })
                       .withDisposed((){
                                           upKey(Key.L);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RUp)
                       .doSubscribe((bool b){
                                                upKey(Key.W);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });
            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                downKey(Key.W);
                                        })
                       .withDisposed((){
                                           upKey(Key.R);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RLeft)
                       .doSubscribe((bool b){
                                                upKey(Key.W);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });


            disposables ~=
            _currentPad.onDownAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                downKey(Key.V);
                                        })
                       .withDisposed((){
                                           upKey(Key.R);
                                       });
            disposables ~=
            _currentPad.onUpAxisButton(AxisButton.RRight)
                       .doSubscribe((bool b){
                                                upKey(Key.V);
                                                downKey(Key.B);
                                                upKey(Key.B);
                                        });

            return disposables;
        }

        auto createDisposableLayer2(){
            Disposable[] disposables;
            disposables ~=
            _currentPad.onDownButton(Button.Y)
                       .doSubscribe((bool b){
                                                downKey(Key.Tab); 
                                                upKey(Key.Tab); 
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.X)
                       .doSubscribe((bool b){
                                                downKey(Key.F6); 
                                                upKey(Key.F6); 
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.B)
                       .doSubscribe((bool b){
                                                downKey(Key.F7); 
                                                upKey(Key.F7); 
                                            });
            disposables ~=
            _currentPad.onDownButton(Button.A)
                       .doSubscribe((bool b){
                                                downKey(Key.F5); 
                                                upKey(Key.F5); 
                                            });
            return disposables;
        }

        void searchPad(){
            import std.algorithm;
            detectAllGamePads();

            Disposable[] disposables;
            bool[] states;
            foreach(pad; _gamepads){
                uint index = _gamepads.countUntil(pad).to!uint;
                states ~= false;
                pad.setupGamePad;
                disposables ~= pad.onUpdateButton(Button.Start).doSubscribe!(value => states[index] = value);
            }

            bool isDetected = false;
            uint detectedPadIndex = 0;
            do{
                SDL_JoystickUpdate();
                foreach(i, pad; _gamepads){
                    _gamepads[i].update;
                    isDetected = states.canFind(true);
                    detectedPadIndex = i;
                    if(isDetected)break;
                }
                import std.algorithm.iteration: stdFold = fold;
                Thread.sleep( dur!("msecs")(100));
            }while(!isDetected);

            foreach(disposable; disposables){
                disposable.dispose();
            }

            writeln("Detected! : ", detectedPadIndex);
            _currentPad = _gamepads[detectedPadIndex];
        }

        void update(){
            if(!_currentPad) return;
            SDL_JoystickUpdate();
            _currentPad.update;
        }
    }//public

    private{
        SDLGamePad _currentPad;
        SDLGamePad[] _gamepads;



        void detectAllGamePads(){
            foreach(joystickIndex; SDL_NumJoysticks().iota){
                auto handle = SDL_JoystickOpen(joystickIndex);
                if(!handle)continue;
                auto pad = new SDLGamePad(handle);
                pad.name.writeln;
                if(pad.isAttached) {
                    SDL_JoystickGetDeviceGUID(joystickIndex).writeln;
                    SDL_JoystickGetAttached(handle).writeln;
                    SDL_JoystickInstanceID(handle).writeln;
                    SDL_GetError.to!string.writeln;
                    _gamepads ~= pad;
                }
            }

            _gamepads.length.writeln;
            SDL_GetError().to!string.writeln;
        }
    }//private
}//class RightCtrl

void downKey(Key key, int flag = 0){
    version(OSX){
        sendKey(key.to!ushort, true, flag);
    }
    version(Windows){
        if(flag == 0){
            sendKey(key.to!ushort, true, 0);
        }else if(flag == 0x00100000){ // ctrl
            sendKey(Key.Control.to!ushort, true, 0);
            sendKey(key.to!ushort, true, 0);
            sendKey(Key.Control.to!ushort, false, 0);
        }else if(flag == 0x00100000){ // ctrl + shift
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
        Control = 0x11,
        Shift = 0x10,
        OpenBracket = 0xDB,
        CloseBracket = 0xDD,
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
    }
}