module keybindable;
import gamepad;
import rx;
interface KeyBindable
{
    void setup(SDLGamePad);
    string name();
    Disposable[] disposables();
}

