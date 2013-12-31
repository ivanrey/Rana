package model {
	import flash.events.EventDispatcher;
	
	import mx.core.mx_internal;
	
	import util.RanaException;

	public class FachadaRana extends EventDispatcher{
		
		public var estado:int;
		public var puntajeMaximo:int;
		private var credito:int;
		private var conf:Configuracion;
		private var recordsVar:Records;
		private var juego:JuegoRana;
		
		public function FachadaRana():void{
			this.conf = new Configuracion();
			this.conf.loadConfiguracion();
			this.puntajeMaximo = -1;
			this.recordsVar = new Records(this.conf);
		}
		
		/**
		 * Este metodo registra el ingreso de credito, y a su vez retorna el numero de jugadores que podrian jugar con 
		 * el tipo de juego seleccionado
		 * @return 	El numero de jugadores posibles
		 */
		public function agregarCredito():int {
			this.credito+=200;
			return this.getCantidadJugadoresCredito();
		}
		public function consultarCredito():int {
			return this.credito;
		}
		public function consultarTurno():int{
			return this.juego.getTurno();
		}
		public function getMaximoBlanqueadas():int{
			return this.conf.getMaxBlanqueadas();
		}
		public function getCantidadJugadoresCredito():int{
			var cantidad:int = this.credito/200;
			return this.puntajeMaximo == 400 ? cantidad : cantidad/2;
		}
		public function setTipoJuego(tipo:int):void{
			if((tipo == Configuracion.cuatroC) || tipo == Configuracion.ochoC)
				this.puntajeMaximo = tipo;
			else
				throw new RanaException('El tipo de juego ingresado no ha sido definido');
		}
		
		public function iniciarJuego():void {
			var numJugadores:int = this.getCantidadJugadoresCredito();
			this.juego = new JuegoRana(this.conf);
			this.juego.setPuntajeMaximo(this.puntajeMaximo);
			this.juego.setNumJugadores(numJugadores);
			this.juego.iniciarJuego();
			this.addListeners();
			
			// Descuento el credito usado
			var valor:int = this.puntajeMaximo == 400 ? 200 : 400;
			this.credito = this.credito - (numJugadores*valor);
		}
		public function sumarPuntos(orificio:int):void {
			this.juego.registrarLanzamiento(orificio);
		}
		public function cambiarTurno(nuevoTurno:int):void{
			this.juego.cambiarTurno(nuevoTurno);
		}
		private function getJugadorActual():Jugador {
			return this.juego.getJugadorEnTurno();
		}
		public function getUltimosPuntajes():Array {
			return new Array(this.getJugadorActual().getUltimosResultados(3), this.getJugadorActual().getCantidadLanzamientos());	
		}
		public function getHighScores(cuantos:int):Array {
			return this.recordsVar.getRecords();
		}
		public function getNumJugadores():int{
			return this.juego.getNumJugadores();
		}
		
		public function getPuntajeMaximo():int{
			return this.puntajeMaximo;
		}
		
		public function analizarRecords():Array{
			var puntajes:Array = this.juego.getPromediosJugadores();
			var records:Array = new Array();
			var esRecord:Boolean = new Boolean();
			for each(var punta:Array in puntajes){
				if(this.recordsVar.analizarRecord(punta[1]))
					records.push(punta);
			}
			return records;
		}
		
		public function salvarRecord(nombre:String, valor:Number):void{
			this.recordsVar.ingresarRecord(valor,nombre);
		}
		
		public function getJugadoresActivos():int{
			return this.juego.getCantidadJugadoresActivos();
		}
		
		private function addListeners():void{
			this.juego.addEventListener(RanaEvento.RANA_ARGOLLA_INSERTADA,fireEvent);
			this.juego.addEventListener(RanaEvento.RANA_TURNO_CAMBIADO,fireEvent);
			this.juego.addEventListener(RanaEvento.RANA_PUNTAJE_CAMBIO,fireEvent);
			this.juego.addEventListener(RanaEvento.RANA_BLANQUEADO,fireEvent);
			this.juego.addEventListener(RanaEvento.RANA_JUGADOR_DESACTIVADO,fireEvent);
			this.juego.addEventListener(RanaEvento.RANA_TERMINAR_JUEGO,fireEvent);
		}
		
		private function fireEvent(event:RanaEvento):void{
			if(event.type == RanaEvento.RANA_TERMINAR_JUEGO)
				this.puntajeMaximo = -1;
			dispatchEvent(new RanaEvento(event.type,event.params));
		}
	}
}