module gamepad;
import rx;
import derelict.sdl2.sdl;
import std.conv;
import std.algorithm:each, canFind;
import keybindable;

enum Axis{
    LHorizontal, 
    LVertical, 
    RHorizontal, 
    RVertical, 
}

static Axis[AxisButton] axisButtonToAxisTable(){
    Axis[AxisButton] table;

    table[AxisButton.LLeft] = Axis.LHorizontal;
    table[AxisButton.LRight]  = Axis.LHorizontal;
    table[AxisButton.LUp] = Axis.LVertical;
    table[AxisButton.LDown]  = Axis.LVertical;

    table[AxisButton.RLeft] = Axis.RHorizontal;
    table[AxisButton.RRight]  = Axis.RHorizontal;
    table[AxisButton.RUp] = Axis.RVertical;
    table[AxisButton.RDown]  = Axis.RVertical;
    return table;
}

static int[AxisButton ]axisButtonToDirectionTable(){
    int[AxisButton] table;
    table[AxisButton.LLeft] = -1;
    table[AxisButton.LRight]  = 1;
    table[AxisButton.LUp] = -1;
    table[AxisButton.LDown]  = 1;

    table[AxisButton.RLeft] = -1;
    table[AxisButton.RRight]  = 1;
    table[AxisButton.RUp] = -1;
    table[AxisButton.RDown]  = 1;
    return table;
}

static AxisButton[int][Axis] axisButtonTable(){
    AxisButton[int][Axis] table;
    table[Axis.LHorizontal][-1] = AxisButton.LLeft;
    table[Axis.LHorizontal][1]  = AxisButton.LRight;
    table[Axis.LVertical][-1] = AxisButton.LUp;
    table[Axis.LVertical][1]  = AxisButton.LDown;

    table[Axis.RHorizontal][-1] = AxisButton.RLeft;
    table[Axis.RHorizontal][1]  = AxisButton.RRight;
    table[Axis.RVertical][-1] = AxisButton.RUp;
    table[Axis.RVertical][1]  = AxisButton.RDown;
    return table;
}

enum AxisButton{
    LLeft, 
    LRight, 
    LUp, 
    LDown, 
    RLeft, 
    RRight, 
    RUp, 
    RDown
}

enum Button
{
    CrossUp,
    CrossDown,
    CrossLeft,
    CrossRight, 
    A,
    B,
    X,
    Y,
    L1,
    R1,
    L2,
    R2,
    Select,
    Start,
    LeftStick,
    RightStick,
    None, 
}  

enum Direction{
    Plus = 1.0f,
    Minus = -1.0f
}

///
class SDLGamePad{
    public{
        
        this(int index){
            _handle = SDL_JoystickOpen(index);
        }

        this(SDL_Joystick* handle){
            _handle = handle;
        }

        ~this(){
            SDL_JoystickClose(_handle);
        }

        float threshold()const{
            return _threshold;
        }

        SDLGamePad threshold(in float v){
            _threshold = v;
            return this;
        }

        float getAxis(Axis axis){
            auto sdlAxis= _registerAxises[axis];
            return SDL_JoystickGetAxis(_handle, sdlAxis).to!float / 32768f;
        }

        bool isHat(Button button){
            return button == Button.CrossUp || button == Button.CrossDown || button == Button.CrossLeft || button == Button.CrossRight;
        }

        bool getButton(Button button){
            if(isHat(button)){
                return getHat(button);
            }
            auto sdlButton = _registerButtons[button];
            return SDL_JoystickGetButton(_handle, sdlButton).to!bool;
        }

        bool getHat(Button hatButton){
            int sdlHat = 0;
            switch(hatButton){
                case Button.CrossUp:
                    sdlHat = 1;
                    break;
                case Button.CrossDown:
                    sdlHat = 4;
                    break;
                case Button.CrossRight:
                    sdlHat = 2;
                    break;
                case Button.CrossLeft:
                    sdlHat = 8;
                    break;
                default:
                    break;
            }
            return SDL_JoystickGetHat(_handle, 0) == sdlHat;
        }

        void setupKeyBind(KeyBindable bindable){
            bindable.setup();
        }

        bool getButtonFromAxis(Button button, Direction direction){
            uint sdlAxis;
            if(direction == Direction.Plus){
                sdlAxis = _registerButtonsFromAxisPlusDir[button];
            }else{
                sdlAxis = _registerButtonsFromAxisMinusDir[button];
            }
            auto v = SDL_JoystickGetAxis(_handle, sdlAxis).to!float / 32768f;
            import std.math: abs;
            return v*direction > _threshold;
        }

        bool isAttached(){
            return SDL_JoystickGetAttached(_handle).to!bool;
        }

        string name(){
            return SDL_JoystickName(_handle).to!string;
        }

        string guidString(){
            auto guid = SDL_JoystickGetGUID(_handle);
            char* str;
            str = SDL_JoystickGetGUIDString(guid);
            return str.to!string;
        }

        SubjectObject!float onUpdateAxis(Axis axis){
            if(!_updateAxisSubjects.keys.canFind(axis)) _updateAxisSubjects[axis] = new SubjectObject!float();
            return _updateAxisSubjects[axis];
        }

        auto onUpdateAxisDictinctly(Axis axis){
            return onUpdateAxis(axis).map!((v){
                                                  if(-_threshold<v&&v<_threshold)return 0;
                                                  if(v<_threshold)return -1f;
                                                  return 1f;
                                              });
        }

        auto onUpdateAxisButton(AxisButton axisButton){
            auto axis = axisButtonToAxisTable[axisButton];
            auto direction = axisButtonToDirectionTable[axisButton];
            import std.math;
            return onUpdateAxisDictinctly(axis).map!(v => fmax(+0, v*direction))
                                               .map!(v => !approxEqual(v, 0));
        }

        auto onDownAxisButton(AxisButton axisButton){
            return onUpdateAxisButton(axisButton).uniq
                                                 .filter!(v => v);
        }

        Observable!bool onUpAxisButton(AxisButton axisButton){
            auto result = (new SubjectObject!bool);
            Disposable updateAxisButton;
            onDownAxisButton(axisButton).doSubscribe!((_){
                    if(updateAxisButton)updateAxisButton.dispose();
                    updateAxisButton = onUpdateAxisButton(axisButton).uniq
                                  .filter!(v => !v)
                                  .map!(v => !v)
                                  .doSubscribe!(v => result.put(v));
                });
            return result;
        }

        SubjectObject!bool onUpdateButton(Button button){
            if(!_updateButtonSubjects.keys.canFind(button)) _updateButtonSubjects[button] = new SubjectObject!bool();
            return _updateButtonSubjects[button];
        }

        auto onDownButton(Button button){
            return onUpdateButton(button).uniq
                                         .filter!(v => v);
        }

        Observable!bool onUpButton(Button button){
            auto result = (new SubjectObject!bool);
            Disposable updateButton;
            onDownButton(button).doSubscribe!((_){
                    if(updateButton)updateButton.dispose();
                    updateButton = onUpdateButton(button).uniq
                                  .filter!(v => !v)
                                  .map!(v => !v)
                                  .doSubscribe!(v => result.put(v));
                });
            return result;
        }

        Observable!bool onStayButtonPeriodicly(Button button){
            Disposable buttonLongPress;
            Disposable buttonUpdate;
            auto subjectButtonStayPeriodicly = (new SubjectObject!bool);
            auto buttonDown = onDownButton(button).doSubscribe!((value){
                                                                           subjectButtonStayPeriodicly.put(true);
                                                                           buttonLongPress = onUpdateButton(button).filter!(v => v)
                                                                                                                   .take(_offset)
                                                                                                                   .takeLast
                                                                                                                   .doSubscribe!((value){
                                                                                                                                            buttonUpdate = onUpdateButton(button).filter!(v => v)
                                                                                                                                                                                 .doSubscribe!(value => subjectButtonStayPeriodicly.put(true));
                                                                                                                                        });
                                                                       });
            auto buttonUp = onUpButton(button).filter!(v => v)
                                              .doSubscribe!((value){
                                                                       if(buttonUpdate)buttonUpdate.dispose();
                                                                       if(buttonLongPress)buttonLongPress.dispose();
                                                                   });
            return subjectButtonStayPeriodicly;
        }

        Observable!bool onStayAxisButtonPeriodicly(AxisButton button){
            Disposable buttonLongPress;
            Disposable buttonUpdate;
            auto subjectStayPeriodicly = (new SubjectObject!bool);
            auto buttonDown = onDownAxisButton(button).doSubscribe!((value){
                                                                           subjectStayPeriodicly.put(true);
                                                                           buttonLongPress = onUpdateAxisButton(button).filter!(v => v)
                                                                                                                       .take(_offset)
                                                                                                                       .takeLast
                                                                                                                       .doSubscribe!((value){
                                                                                                                                            buttonUpdate = onUpdateAxisButton(button).filter!(v => v)
                                                                                                                                                                                 .doSubscribe!(value => subjectStayPeriodicly.put(true));
                                                                                                                                        });
                                                                       });
            auto buttonUp = onUpAxisButton(button).filter!(v => v)
                                              .doSubscribe!((value){
                                                                       if(buttonUpdate)buttonUpdate.dispose();
                                                                       if(buttonLongPress)buttonLongPress.dispose();
                                                                   });
            return subjectStayPeriodicly;
        }


        SDLGamePad update(){
            import std.range;
            import std.stdio;
            foreach(i; 4.iota) {
                auto status = SDL_JoystickGetHat(_handle, 0);
                writeln(i, ": ", status);
            }

            _registerButtons.keys.each!(button => _updateButtonSubjects[button].put(getButton(button)));
            _registerButtonsFromAxisPlusDir.keys.each!(button => _updateButtonSubjects[button].put(getButtonFromAxis(button, Direction.Plus)));
            _registerButtonsFromAxisMinusDir.keys.each!(button => _updateButtonSubjects[button].put(getButtonFromAxis(button, Direction.Minus)));
            _registerAxises.keys.each!(axis => _updateAxisSubjects[axis].put(getAxis(axis)));
            return this;
        };

        SDLGamePad registerAxis(Axis axis, int id){
            _registerAxises[axis] = id;
            if(!_updateAxisSubjects.keys.canFind(axis)) _updateAxisSubjects[axis] = new SubjectObject!float();
            return this;
        }

        SDLGamePad registerButton(Button button, int id){
            _registerButtons[button] = id;
            if(!_updateButtonSubjects.keys.canFind(button)) _updateButtonSubjects[button] = new SubjectObject!bool();
            return this;
        }

        SDLGamePad registerButtonFromAxis(Button button, int axisId, Direction dir){
            if(dir == Direction.Plus){
                _registerButtonsFromAxisPlusDir[button] = axisId;
            }else{
                _registerButtonsFromAxisMinusDir[button] = axisId;
            }
            if(!_updateButtonSubjects.keys.canFind(button)) _updateButtonSubjects[button] = new SubjectObject!bool();
            return this;
        }
    }//public

    private{
        SDL_Joystick* _handle;
        SubjectObject!float[Axis] _updateAxisSubjects;
        SubjectObject!bool[Button] _updateButtonSubjects;
        int[Axis] _registerAxises;
        int[Button] _registerButtons;
        int[Button] _registerButtonsFromAxisPlusDir;
        int[Button] _registerButtonsFromAxisMinusDir;
        float _threshold = 0.8;
        int _offset = 20;
    }//private
}//class GamePad

SDLGamePad setupGamePad(SDLGamePad pad){
    version(OSX){
        pad.threshold(0.8)
           .registerAxis(Axis.LHorizontal, 0)
           .registerAxis(Axis.LVertical,   1)
           .registerAxis(Axis.RHorizontal, 2)
           .registerAxis(Axis.RVertical,   3)
           .registerButton(Button.Select,   0)
           .registerButton(Button.Start,    3)
           .registerButton(Button.RightStick, 2)
           .registerButton(Button.LeftStick,  1)
           .registerButton(Button.L1, 10)
           .registerButton(Button.L2, 8)
           .registerButton(Button.R1, 11)
           .registerButton(Button.R2, 9)
           .registerButton(Button.CrossUp,    4)
           .registerButton(Button.CrossDown,  6)
           .registerButton(Button.CrossLeft,  7)
           .registerButton(Button.CrossRight, 5)
           .registerButton(Button.Y, 12)
           .registerButton(Button.A, 14)
           .registerButton(Button.X, 15)
           .registerButton(Button.B, 13);
    }
    version(Windows){
        pad.threshold(0.8)
           .registerAxis(Axis.RHorizontal, 3)
           .registerAxis(Axis.RVertical,   4)
           .registerButton(Button.Select,   6)
           .registerButton(Button.Start,    7)
           .registerButton(Button.RightStick, 9)
           .registerButton(Button.LeftStick, 8)
           .registerButtonFromAxis(Button.L2, 5, Direction.Minus)
           .registerButtonFromAxis(Button.R2,  5, Direction.Plus)
           .registerButton(Button.L1, 4)
           .registerButton(Button.R1, 5)
           .registerButton(Button.Y, 3)
           .registerButton(Button.A, 0)
           .registerButton(Button.X, 2)
           .registerButton(Button.B, 1)
           .registerButton(Button.CrossUp, 0)
           .registerButton(Button.CrossDown, 0)
           .registerButton(Button.CrossLeft, 0)
           .registerButton(Button.CrossRight, 0);
    }
    return pad;
}
