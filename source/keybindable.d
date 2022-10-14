module keybindable;
import gamepad;
import rx;
interface KeyBindable
{
    Disposable[] setup(SDLGamePad);
    string name();
}

