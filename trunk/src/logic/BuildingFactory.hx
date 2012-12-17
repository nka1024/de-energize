package logic;
import building.Building;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class BuildingFactory
{

	public function new()
	{
		
	}
	
	public function getRandomBuilding():Building
	{
		return new Building();
	}
}