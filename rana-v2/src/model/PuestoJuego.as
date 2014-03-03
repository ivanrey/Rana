package model
{
	public class PuestoJuego
	{

		[Bindable]
		public var numJugador:int;
		[Bindable]
		public var chicosPerdidos:int;
		
		public function PuestoJuego(numJugador:int)
		{
			this.numJugador = numJugador;
		}
		
	}
}