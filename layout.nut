////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////   

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below";
   </ label="Select background image", help="Select background", options="background_1", order=2 /> enable_background="background_1";
   </ label="Select wheel type", help="Select wheel type or listbox", options="horizontal", order=4 /> enable_list_type="horizontal";
   </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=5 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=6 /> transition_ms="35";  
</ label="--------    Extra images     --------", help="Show or hide additional images", order=9 /> uct2="select below";
   </ label="Enable box art", help="Select box art", options="Yes,No", order=10 /> enable_gboxart="Yes";
   </ label="Enable cartridge art", help="Select cartridge art", options="Yes,No", order=11 /> enable_gcartart="Yes";
</ label="--------    Extras     --------", help="Extra layout options", order=15 /> uct2="select below"; 
   </ label="Enable flyer animation", help="Select yes or no", options="Yes,No", order=16 /> enable_gflyer="No";
   </ label="Random Wheel Sounds", help="Play random sounds when navigating games wheel", options="Yes,No", order=25 /> enable_random_sound="Yes";   
}

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
//fe.layout.font="Roboto";

// modules
fe.load_module("fade");
fe.load_module( "animate" );

/////////////////////////////////////////////

//create surface for snap
local surface_snap = fe.add_surface( 640, 480 );
local snap = FadeArt("snap", 0, 0, 640, 480, surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = true;

//now position and pinch surface of snap
//adjust the below values for the game video preview snap
surface_snap.set_pos(flx*0.475, fly*0.163, flw*0.5, flh*0.53);
surface_snap.skew_y = 0;
surface_snap.skew_x = 0;
surface_snap.pinch_y = 0;
surface_snap.pinch_x = 0;
surface_snap.rotation = 0;
surface_snap.preserve_aspect_ratio = true;

/////////////////////////////////////////////
// Load background image
if ( my_config["enable_background"] == "background_1" )
{
local bgsolid = fe.add_image( "backgrounds/background_1.png", 0, 0, flw, flh );
bgsolid.alpha=255;
}

//////////////////////////////////////////////////////////////////////////////////
// The following section sets up the wheel art

//horizontal wheel
if ( my_config["enable_list_type"] == "horizontal" )
{
fe.load_module( "conveyor" );
local wheel_x = [ -flx*1.3, -flx*1.2, flx*0.0, flx*0.1, flx*0.2 flx*0.3, flx*0.4, flx*0.57, flx*0.67, flx*0.77, flx*0.87, flx*0.97 ];
local wheel_y = [ fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.8, fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.784, ]; 
local wheel_w = [ flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.2, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, ];
local wheel_h = [  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, flh*0.175,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, ];
local wheel_a = [  100,  100,  100,  100,  100,  100, 255,  100,  100,  100,  100,  100, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 10;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
		//preserve_aspect_ratio = true;
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}

//////////////////////////////////////////////////////////////////////////////////
// Play random sound when transitioning to next / previous game on wheel
function sound_transitions(ttype, var, ttime) 
{
	if (my_config["enable_random_sound"] == "Yes")
	{
		local random_num = floor(((rand() % 1000 ) / 1000.0) * (124 - (1 - 1)) + 1);
		local sound_name = "sounds/GS"+random_num+".mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
}
fe.add_transition_callback("sound_transitions")

//////////////////////////////////////////////////////////////////////////////////
// Game information
//Title text info
local textt = fe.add_text( "[Title]", flx*0.05, fly*0.15, flw*0.41, flh*0.035  );
textt.set_rgb( 225, 255, 255 );
//textt.style = Style.Bold;
textt.align = Align.Centre;
textt.rotation = 0;
textt.word_wrap = true;

//Game count text info
local textgc = fe.add_text( "Game Count: [ListEntry]-[ListSize]", flx*0.05, fly*0.2, flw*0.4, flh*0.035  );
textgc.set_rgb( 225, 255, 255 );
//textgc.style = Style.Bold;
textgc.align = Align.Left;
textgc.rotation = 0;
textgc.word_wrap = true;

//Filter text info
local textf = fe.add_text( "Filter: [ListFilterName]", flx*0.305, fly*0.2, flw*0.4, flh*0.035  );
textgc.set_rgb( 225, 255, 255 );
//textgc.style = Style.Bold;
textf.align = Align.Left;
textf.rotation = 0;
textf.word_wrap = true;

//Year text info
local texty = fe.add_text("Year: [Year]", flx*0.05, fly*0.25, flw*0.13, flh*0.035 );
texty.set_rgb( 255, 255, 255 );
//texty.style = Style.Bold;
texty.align = Align.Left;

//Players text info
local textpl = fe.add_text("Players: [Players]", flx*0.16, fly*0.25, flw*0.175, flh*0.035 );
textpl.set_rgb( 255, 255, 255 );
//textpl.style = Style.Bold;
textpl.align = Align.Left;

//Played Count text info
local textplc = fe.add_text("Played Count: [PlayedCount]", flx*0.305, fly*0.25, flw*0.175, flh*0.035 );
textplc.set_rgb( 255, 255, 255 );
//textplc.style = Style.Bold;
textplc.align = Align.Left;

//Manufacturer text info
local textm = fe.add_text("Manufacturer: [Manufacturer]", flx*0.05, fly*0.3, flw*0.35, flh*0.035 );
textm.set_rgb( 255, 255, 255 );
//textm.style = Style.Bold;
textm.align = Align.Left;

//Emulator text info
local textemu = fe.add_text( "[Emulator]", flx*0.05, fly*0.35, flw*0.6, flh*0.035  );
textemu.set_rgb( 225, 255, 255 );
//textemu.style = Style.Bold;
textemu.align = Align.Left;
textemu.rotation = 0;
textemu.word_wrap = true;


//category icons 

local glogo1 = fe.add_image("glogos/unknown1.png", flx*0.21, fly*0.4125, flw*0.04, flh*0.07);
glogo1.trigger = Transition.EndNavigation;

class GenreImage1
{
    mode = 1;       //0 = first match, 1 = last match, 2 = random
    supported = {
        //filename : [ match1, match2 ]
        "action": [ "action","gun", "climbing" ],
        "adventure": [ "adventure" ],
        "arcade": [ "arcade" ],
        "casino": [ "casino" ],
        "computer": [ "computer" ],
        "console": [ "console" ],
        "collection": [ "collection" ],
        "fighter": [ "fighting", "fighter", "beat-'em-up" ],
        "handheld": [ "handheld" ],
		"jukebox": [ "jukebox" ],
        "platformer": [ "platformer", "platform" ],
        "mahjong": [ "mahjong" ],
        "maze": [ "maze" ],
        "paddle": [ "breakout", "paddle" ],
        "puzzle": [ "puzzle" ],
	    "pinball": [ "pinball" ],
	    "quiz": [ "quiz" ],
	    "racing": [ "racing", "driving","motorcycle" ],
        "rpg": [ "rpg", "role playing", "role-playing" ],
	    "rhythm": [ "rhythm" ],
        "shooter": [ "shooter", "shmup", "shoot-'em-up" ],
	    "simulation": [ "simulation" ],
        "sports": [ "sports", "boxing", "golf", "baseball", "football", "soccer", "tennis", "hockey" ],
        "strategy": [ "strategy"],
        "utility": [ "utility" ]
    }

    ref = null;
    constructor( image )
    {
        ref = image;
        fe.add_transition_callback( this, "transition" );
    }
    
    function transition( ttype, var, ttime )
    {
        if ( ttype == Transition.ToNewSelection || ttype == Transition.ToNewList )
        {
            local cat = " " + fe.game_info(Info.Category, var).tolower();
            local matches = [];
            foreach( key, val in supported )
            {
                foreach( nickname in val )
                {
                    if ( cat.find(nickname, 0) ) matches.push(key);
                }
            }
            if ( matches.len() > 0 )
            {
                switch( mode )
                {
                    case 0:
                        ref.file_name = "glogos/" + matches[0] + "1.png";
                        break;
                    case 1:
                        ref.file_name = "glogos/" + matches[matches.len() - 1] + "1.png";
                        break;
                    case 2:
                        local random_num = floor(((rand() % 1000 ) / 1000.0) * ((matches.len() - 1) - (0 - 1)) + 0);
                        ref.file_name = "glogos/" + matches[random_num] + "1.png";
                        break;
                }
            } else
            {
                ref.file_name = "glogos/unknown1.png";
            }
        }
    }
}
GenreImage1(glogo1);

/////////////////////////////////////////////
// Flyer

local flyerstatic = fe.add_image("flyer/[Emulator]", flx*0.06, fly*0.39, flw*0.14 flh*0.325 );

//////////////////////////////////////////////////////////////////////////////////
// Box art/Cart art to display, uses the emulator.cfg path for image location

// Static media style
if ( my_config["enable_gboxart"] )
{
local boxartstatic = fe.add_artwork("boxart", flx*0.275, fly*0.385, flw*0.15, flh*0.33 );
boxartstatic.preserve_aspect_ratio = true;
}

if ( my_config["enable_gcartart"] == "Yes" )
{
local cartartstatic = fe.add_artwork("cartart", flx*0.39, fly*0.565, flw*0.125, flh*0.125 );
cartartstatic.preserve_aspect_ratio = true;
}
