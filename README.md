# Desktop Operator

A little operator that lives on your desktop. A chibi character walks back and forth at the bottom of your screen, alternating between standing still and strolling around, always nearby while you work or play.

Click on it anytime to see a special reaction (WOP).


# !! DISCLAIMER !!

I **DO NOT**, I repeat, I DO **NOT OWN** any of the chibis images, animations, voices or anything else, they're propriety of Hypergryph,
a chinese game developer which develops the mobile game Arknights, they have total credit and ownership of
the arts, animations, voices and everything related to the chibis of each character and skin of this game.

I'm just using for a little non profitabble fan project!!


## What it is

Desktop Operator is a "desktop pet" — a small animated character that stays on top of your desktop, keeping you company throughout your day at the computer. No windows, no flashy menus: just a cute character casually wandering across your screen.

The idea was born out of love for the Operators from Arknights, bringing these characters out of the game and into your everyday computer life.


## How the experience works

- The character naturally alternates between standing still and walking, at varying intervals, giving the feeling that it's truly "alive" on your screen.
- It moves freely across the width of the screen, choosing new destinations spontaneously.
- Clicking on it triggers a small reaction, making the experience more interactive.

## HOW TO GET YOUR CHARACTER IN THE GAME

Because Arknights has so, so many operators, in the end with like a bit more than ten characters the export executable
starts to get really heavy (almost 1GB!), so I choose to disponible files that you can download and have you pick what character
you want inside the game.

**To have them inside the game**:
1) Downlaod their file in one of the releases or just ask me (contact in the end).

2) Create a folder in the same area the game executable (.exe or .x86_64) called "characters"

3) Put the file of the any operator (or all of them) inside the folder

4) Click two times on the executable and it will be in the game!


## Future implementations

- **stun animmations**: Make you bully them
- **entering animation**: Add entering animation when changing characters
- **Add more characters voices**: Currently all characters has EN and JP, plus native language if have, I will add KR and CN to all of them (maybe).
- **New characters**: expand the available roster, allowing you to choose between different Operators to keep you company on screen.
- **Skin purchases**: visual variations for the characters, available for purchase.

### Ideas under consideration

- **Combat minigame**: a possible future addition, still being evaluated for feasibility and how much it would add to the experience.
- **Full idle game**: maybe a more solid future for this project, but still being evaluated.

## How to launch

Both should be ootb, but Linux being Linux

I do not guarantee it will work or that you will for some reason damage
your computer, but you're welcome to ask me for help and give ideas!

- **Windows**: Just execute the goddam .exe

- **Linux** (do **not** use sudo on any of this steps if it doesn't work):
	1) Make it executable:
	```
	chmod +x /path/to/file/LINUX.DesktopOperator.x86_64
	```
	
	2) Execute the file from terminal
	```
	./path/to/file/LINUX.DesktopOperator.x86_64
	```
	
	3) (Optional) Create a desktop entry to launch without a terminal
		
		3.1) Create the file DesktopOperator.desktop on ```~/.local/share/applications/``` (create any folders if needed)
		
		3.2) Open the created file and put this on it
		```
		[Desktop Entry]
		Type=Application
		Name=Desktop Operator
		Exec=/path/to/file/LINUX.DesktopOperator.x86_64
		Icon=/path/to/icon.png
		Terminal=false
		Categories=Utility;
		```
		Obs.: I don't have a icon yet
		
	4) (Optional and circustancial) If you use a Tailing/Scrolling Window Manager like me (I use Niri btw)
	you might want to add something like that to your config file, if you don't the
	window of the "game" might not be the size it should.
	```
	//Desktop Operator
	window-rule {
    	match app-id="^DesktopOperator$"
    	open-floating true
    	default-floating-position x=0 y=0 relative-to="bottom-right"
    	default-column-width { fixed 640; }
    	default-window-height { fixed 150; }
	}
	```
	Obs.: This is for Niri only, search the how to on your desktop environment


## There is something I can do? How can I help?

**characters sprites**
Well, the most help would be getting the operators files. I'm using PRTS Wiki, but idk if it's bc they're on the other end
of the world or if they simple, don't have the files.

Note: Don't use the download button since I get a better result just having the raw files and putting them together.

The Arknights chibis use Spine, a software to rig and animate the sprites of the game, you can extract
this files (.atlas, .skel, .png) and send to me on Discord to add new characters and their skins!

You can still get this files from PRTS Wiki, opening the web dev tools with F12, goingg to the network tab and relaod the page,
go to the bottom of the character page and should appear at the bottom the build_char<etc>.atlas/.skel/.png files. Double click on their
names and you should be able to download it.

**characters voices**
You can get those in Arknits Tera Wiki, go to a character profile then to the dialogues tab.

**Contac me trought**	 
Discord: re.daemon	
Reddit: u/Bodewilson
