module keyboard;
import keyutils;

class Keyboard(){
    public{
        this(){}

        ~this(){}

        void downKey(Key key, int flag = 0){
            isPressed[flag][key] = true;
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
            isPressed[flag][key] = false;
            sendKey(key.to!ushort, false, flag);
        }

        void reset(){
            foreach(flag; isPressed.keys){
                foreach(key; isPressed[flag]){
                    if(isPressed[flag][key]){
                        isPressed[flag][key] = false;
                        upKey(key, flag);
                    }
                }
            }
        }
    }

    bool[string][int] isPressed;
}

