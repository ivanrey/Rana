package model {
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import util.RanaException;

	public class FachadaRana extends EventDispatcher{
		
		public var estado:int;
		public var puntajeMaximo:int;
		private var credito:int;
		private var conf:Configuracion;
		private var recordsVar:Records;
		private var juego:JuegoRana;
		private var participantesPorJugador:int;
		
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
			this.credito++;
			
			this.sonar("moneda");
			return this.getCantidadJugadoresCredito();
		}
		
		public function sonar(sonido:String):void{
			var sonidoMoneda:Sound = new Sound();
			sonidoMoneda.load(new URLRequest("/assets/sonidos/"+sonido+".mp3"));
			sonidoMoneda.play();
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
			return this.puntajeMaximo > 1200 ? this.credito: this.credito/2; // por ahora un credito por jugador sin importar el puntaje
		}
		public function setTipoJuego(tipo:int):void{
			if((tipo == Configuracion.cuatroC) || tipo == Configuracion.ochoC || 
				tipo == Configuracion.milDoscientos || tipo == Configuracion.milOchocientos || tipo == Configuracion.milSeiscientos || tipo == Configuracion.dosMil)
				this.puntajeMaximo = tipo;
			else
				throw new RanaException('El tipo de juego ingresado no ha sido definido');
		}
		
		public function iniciarJuego():void {
			var numJugadores:int = this.getCantidadJugadoresCredito();
			this.juego = new JuegoRana(this.conf);
			this.juego.setPuntajeMaximo(this.puntajeMaximo);
			this.juego.setNumJugadores(numJugadores);
			this.juego.setParticipantesPorJugador(this.participantesPorJugador);
			this.juego.iniciarJuego();
			
			this.addListeners();
			
			// Descuento el credito usado
			var valor:int = this.puntajeMaximo > 1200 ? 1 : 2;
			this.credito = this.credito - (numJugadores*valor);
			
			this.sonar("inicio");
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
		
		public function getMaxLanzamientos():int{
			return this.juego.getMaxLanzamientos();
		}
		
		public function setParticipantePorJugador( participantes:int):void{
			this.participantesPorJugador = participantes;
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
			
			switch(event.type){
				case RanaEvento.RANA_BLANQUEADO:
					this.sonar("blanqueado");
					break;
				case RanaEvento.RANA_ARGOLLA_INSERTADA:
					this.sonar("lanzamiento");
					break;
				case RanaEvento.RANA_TURNO_CAMBIADO:
					this.sonar("cambioturno");
					break;
				case RanaEvento.RANA_JUGADOR_DESACTIVADO:
					this.sonar("jugadoreliminado");
					break;
				case RanaEvento.RANA_TERMINAR_JUEGO:
					this.sonar("blanqueado");
					break;
						
			}
				
		}
	}
}