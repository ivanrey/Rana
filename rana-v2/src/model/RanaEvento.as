package model{
	import flash.events.Event;
	
	public class RanaEvento extends Event{
		
		// Declaracion de los tipos de eventos
		public static const RANA_BLANQUEADO:String = "JugadorBlanqueado";
		public static const RANA_TERMINAR_JUEGO:String = "TerminarJuego";
		public static const RANA_JUGADOR_DESACTIVADO:String = "JugadorDesactivado";
		public static const RANA_RANA_GRANDE:String = "Rana";
		public static const RANA_RANA_PEQUENA:String = "RanaPequena";
		public static const RANA_ARGOLLA_INSERTADA:String = "ArgollaInsertada";
		public static const RANA_TURNO_CAMBIADO:String = "TurnoCambiado";
		public static const RANA_PUNTAJE_CAMBIO:String = "CambioPuntajeJugador";
		
		public static const FIN_JUEGO_NORMAL:String = "FinJuego";
		public static const FIN_JUEGO_BLANQUEADO:String = "FinJuegoBlanqueados";
		
		public static const GANADOR:String = "Ganador";
		public static const MONONA:int = 5;
		
		public var params:*;
		
		public function RanaEvento(type:String, params:* = null, bubbles:Boolean=false, cancelable:Boolean=false){
			this.params = params;
			super(type, bubbles, cancelable);
		}
		
		public function getParams():*{
			return this.params;
		}
		
		// Sobrecargamos el metodo clone para devolver un objeto listener de mi misma clase
		override public function clone():Event{
			return new RanaEvento(type);
		}
	}
}