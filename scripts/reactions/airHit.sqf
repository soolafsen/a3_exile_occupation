_heli = _this select 0;
_heli removeAllMPEventHandlers  "mphit";
_heliDamage = getDammage _heli;
_heliPosition = getPosATL _heli;
_heliHeight = getPosATL _heli select 2;
_crewEjected = _heli getVariable "SC_crewEjected";

_damageLimit 		= 0.2;
_engineDamage 		= false;
_fueltankDamage 	= false;

if(SC_extendedLogging) then 
{
	_logDetail = format ["[OCCUPATION:Sky]:: Air unit %2 hit by %3 at %1 (damage: %4)",time,_this select 0,_this select 1,_heliDamage];
	[_logDetail] call SC_fnc_log;	
};
_ejectChance = round (random 100) + (_heliDamage * 100);

if(_heliDamage > 0.2 && !_crewEjected && _ejectChance > 100) then
{
	_target = _this select 1;
	[_heli, _target] spawn 
	{
		_veh = _this select 0;
        _group2 = createGroup east;
        if(SC_extendedLogging) then 
        { 
            _heliPosition = getPosATL _veh;
            _logDetail = format ["[OCCUPATION:Sky]:: Air unit %2 ejecting passengers at %3 (time: %1)",time,_veh,_heliPosition]; 
            [_logDetail] call SC_fnc_log;	
        };
        _cargo = assignedCargo _veh;
		{				
            _x joinSilent _group2;
			_x action ["EJECT", _veh];
		} forEach _cargo;
        
        _target = _this select 1;
        _group2 reveal [_target,1.5];

        _destination = getPos _target;
        _group2 allowFleeing 0;
        _wp = _group2 addWaypoint [_destination, 0] ;
        _wp setWaypointFormation "Column";
        _wp setWaypointBehaviour "COMBAT";
        _wp setWaypointCombatMode "RED";
        _wp setWaypointCompletionRadius 1;
        _wp setWaypointType "SAD";
             
        [_group2, _destination, 500] call bis_fnc_taskPatrol;
        _group2 allowFleeing 0;
        _group2 setBehaviour "AWARE";  
        _group2 setCombatMode "RED";	
	};
	_heli setVariable ["SC_crewEjected", true,true];
		
};
	

if(_heliDamage > 0.7) then
{
	if(SC_extendedLogging) then 
	{ 
		_logDetail = format ["[OCCUPATION:Sky]:: Air unit %2 damaged and force landing at %3 (time: %1)",time,_this select 0,_this select 1,_heliPosition];
		[_logDetail] call SC_fnc_log;
	};
    
    [_heli] call SC_fnc_vehicleDestroyed;
    _currentHeliPos = getPos _heli;
    _destination = [_currentHeliPos, 1, 150, 10, 0, 20, 0] call BIS_fnc_findSafePos;
	_heli setVehicleLock "UNLOCKED";
	_target = _this select 1;
	_group = group _heli;
	_group reveal [_target,2.5];
    _destination = position _target;

    _heli land "LAND";
    _group2 = createGroup east;
    {
        _x join _group2;
    } forEach (fullCrew _heli);

	_group2 allowFleeing 0;
	_wp = _group2 addWaypoint [_destination, 0] ;
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointCombatMode "RED";
	_wp setWaypointCompletionRadius 10;
	_wp setWaypointType ""TR UNLOAD"";    
    
	[_group2, _destination, 250] call bis_fnc_taskPatrol;
    _group2 setBehaviour "COMBAT";
    _group2 setCombatMode "RED";
};

if(_heliDamage <= 0.7) then
{
    _heli addMPEventHandler ["mphit", "_this call SC_fnc_airHit;"];
};