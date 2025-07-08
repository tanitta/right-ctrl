module keybindable;
import gamepad;
import rx;
import keyboard;
interface KeyBindable
{
    void setup(SDLGamePad, Keyboard);
    string name();
    Disposable[] disposables();
}

