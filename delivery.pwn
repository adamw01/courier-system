#define FILTRTSCRIPT

#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <foreach>

#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) 

new Float: DeliveryCP[][3] =// all near los santos airport
{
	{1894.2181,-2133.8342,15.4663},
    {1872.5140,-2133.4617,15.4820},
    {1851.8079,-2135.4785,15.3882},
    {1804.1733,-2124.5183,13.9424},
    {1802.0742,-2099.5574,14.0210},
    {1782.1294,-2126.1873,14.0679},
    {1781.5271,-2101.9512,14.0566},
    {1761.2472,-2124.9226,14.0566},
    {1762.4678,-2102.3833,13.8570},
    {1734.7061,-2129.8684,14.0210},
    {1711.6321,-2101.7390,14.0210},
    {1715.0366,-2124.7524,14.0566},
    {1684.7278,-2099.4089,13.8343},
    {1695.4994,-2125.3999,13.8101},
    {1673.7737,-2122.4600,14.1460},
    {1667.4948,-2107.5659,14.0723},
    {1851.8402,-2069.7188,15.4812},
    {1873.6151,-2070.1265,15.4971},
    {1895.4196,-2068.2354,15.6689},
    {1937.9296,-1911.5403,15.2568},
    {1928.5251,-1916.0890,15.2568},
    {1913.4252,-1913.0002,15.2568},
    {1891.9386,-1914.6025,15.2568},
    {1872.1877,-1912.6665,15.2568},
    {1854.1146,-1914.9354,15.2568},
    {1897.8868,-2037.9088,13.5469},
    {1898.4463,-2029.1753,13.5469},
    {1916.7900,-2029.1899,13.5469},
    {1916.8823,-2001.3242,13.5469},
    {1908.0764,-1982.5504,13.5469},
    {1877.7290,-1982.6965,13.5469},
    {1878.1976,-2000.8708,13.5469},
    {1868.0209,-2009.5092,13.5469},
    {1849.1951,-2037.8882,13.5469},
    {1849.4895,-2029.3500,13.5469},
    {1835.8282,-2006.0781,13.5469},
    {1817.5377,-2005.6517,13.5544}
};

new bool:InJob[MAX_PLAYERS];
new bool:DeliveryMan[MAX_PLAYERS];
new Unload_Timer[MAX_PLAYERS];

main(){}

public OnFilterScriptInit()
{
	// copuple of objects for lsa entry and where burrito's are parked.
	CreateObject(3630, 2001.76611, -2221.56958, 14.04580,   0.00000, 0.00000, 90.00000);
	CreateObject(19425, 1964.95703, -2176.78857, 12.56570,   0.00000, 0.00000, 0.00000);
	CreateObject(19425, 1961.65063, -2176.78857, 12.56570,   0.00000, 0.00000, 0.00000);
	CreateObject(19425, 1958.34729, -2176.78857, 12.56570,   0.00000, 0.00000, 0.00000);
	CreateObject(3576, 1996.87439, -2218.30664, 14.04240,   0.00000, 0.00000, 0.00000);
	CreateObject(3577, 1997.40527, -2221.84839, 13.30540,   0.00000, 0.00000, -90.00000);
	CreateObject(1685, 1998.73010, -2225.29907, 13.25740,   0.00000, 0.00000, 0.00000);
	CreateObject(1685, 1996.45435, -2225.28662, 13.25740,   0.00000, 0.00000, 0.00000);
	
	AddStaticVehicle(482, 2006.3612, -2223.2078, 13.6652, 0.0071, 3, 3); // Burrito at LSA
	AddStaticVehicle(482, 2010.3445, -2222.7461, 13.6698, 359.8188, 162, 162); // Burrito at LSA
	AddStaticVehicle(482, 2014.2794, -2222.2490, 13.6675, 357.6033, 3, 3); // Burrito at LSA
	AddStaticVehicle(482, 2021.5011, -2221.8401, 13.6709, 359.1634, 162, 162); // Burrito at LSA
	AddStaticVehicle(482, 2026.4165, -2222.1641, 13.6664, 359.2516, 3, 3);  // Burrito at LSA
	
	Create3DTextLabel("Los Santos International Airport\n Courier Depot", 0x33AA33FF, 1998.9209,-2212.8696,13.5469, 30.0, 0, 0);
	return 1;
}

public OnFilterScriptExit()
{
	foreach(new i: Player)
	{
		DeliveryMan[i] = false;
		InJob[i] = false;
		DisablePlayerCheckpoint(i);
		KillTimer(Unload_Timer[i]);
	}
	
	return 1;
}

public OnPlayerConnect(playerid)
{
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
	
	SetPlayerMapIcon(playerid, 12, 1998.9209,-2212.8696,13.5469, 51 , 0, MAPICON_LOCAL); // Truck Icon at LSA
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
	KillTimer(Unload_Timer[playerid]);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482)
	{
	    if(DeliveryMan[playerid] == true)
	    {
			GameTextForPlayer(playerid, "~r~UNLOADING....", 4000, 3); // or add into notification box on the right
	        Unload_Timer[playerid] = SetTimerEx("FinishJob", 5000, false, "i", playerid);
	        TogglePlayerControllable(playerid,0);
		}
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482)
	{
	    if(DeliveryMan[playerid] == true)
	    {
	        KillTimer(Unload_Timer[playerid]);
	    }
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482)
		{
			GameTextForPlayer(playerid, "~w~COURIER DELIVERY AVALIABLE ~n~PRESS ~y~Y", 5000, 3); // or add into notification box on the right
		}
		return 1;
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PRESSED(KEY_YES))
    {
		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482)
		{
		    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		    {
     			new rand = random(sizeof(DeliveryCP));
				if(InJob[playerid] == true) return SendClientMessage(playerid, 0xFF0000FF, "You're currently in a mission. Please finish it.");
				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482)
				{
					InJob[playerid] = true;
					DeliveryMan[playerid] = true;
					SetPlayerCheckpoint(playerid, DeliveryCP[rand][0], DeliveryCP[rand][1], DeliveryCP[rand][2], 10);
     				GameTextForPlayer(playerid, "~w~COURIER JOB STARTED. DELIVER PACKAGE TO ~n~~r~RED ~w~CHECKPOINT", 5000, 3); // or add into notification box on the right
     				SendClientMessage(playerid, -1, "You can stop the delivery mission by typing /stopwork"); // or add into notification box on the right
				}
     		}
		}
	}
	return 1;
}

COMMAND:stopwork(playerid,params[])
{
    if(DeliveryMan[playerid] == true)
	{
		DeliveryMan[playerid] = false;
		InJob[playerid] = false;
   		DisablePlayerCheckpoint(playerid);
   		SendClientMessage(playerid, 0xFF0000FF, "You've stopped the Courier Delivery Mission. Press 'Y' to start again."); // or add into notification box on the right
	}
	return 1;
}

forward FinishJob(playerid);
public FinishJob(playerid)
{
    new str[128], cash = RandomEx(1000, 8000);
    format(str, sizeof str, "~w~PACKAGE DELIVERED, YOU'VE RECEIVED ~g~$%i ~w~TO DELIVER AGAIN PRESS ~y~Y", cash); // or add into notification box on the right
    GameTextForPlayer(playerid, str, 6000, 3);
    GivePlayerMoney(playerid, cash);
    TogglePlayerControllable(playerid,1);
    DisablePlayerCheckpoint(playerid);
    SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);
    InJob[playerid] = false;
}

RandomEx(min, max) // By Y_Less
{
    return random(max - min) + min;
}
