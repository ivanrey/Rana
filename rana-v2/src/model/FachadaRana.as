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
		private var chico:ChicoRana;
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
			return this.chico.getTurno();
		}
		public function getMaximoBlanqueadas():int{
			return this.conf.getMaxBlanqueadas();
		}
		public function getCantidadJugadoresCredito():int{
			var monedasPorPersona:int = this.puntajeMaximo > 1200 ? this.credito/2: this.credito; // por ahora un credito por jugador sin importar el puntaje
			return Math.floor(monedasPorPersona/this.participantesPorJugador);
		}
		
		public function setTipoJuego(tipo:int):void{
			if((tipo == Configuracion.cuatroC) || tipo == Configuracion.ochoC || 
				tipo == Configuracion.milDoscientos || tipo == Configuracion.milOchocientos || tipo == Configuracion.milSeiscientos || tipo == Configuracion.dosMil)
				this.puntajeMaximo = tipo;
			else
				throw new RanaException('El tipo de juego ingresado no ha sido definido');
		}
		
		public function iniciarChico():void {
			var numJugadores:int = this.getCantidadJugadoresCredito();
			this.chico = new ChicoRana(this.conf);
			this.chico.setPuntajeMaximo(this.puntajeMaximo);
			this.chico.setNumJugadores(numJugadores);
			this.chico.setParticipantesPorJugador(this.participantesPorJugador);
			this.chico.iniciarJuego();
			
			this.addListeners();
			
			// Descuento el credito usado
			var valor:int = this.puntajeMaximo > 1200 ? 1 : 2;
			this.credito = this.credito - (numJugadores*valor);
			
			this.sonar("inicio");
		}
		
		public function sumarPuntos(orificio:int):void {
			this.chico.registrarLanzamiento(orificio);
		}
		public function cambiarTurno(nuevoTurno:int):void{
			this.chico.cambiarTurno(nuevoTurno);
		}
		private function getJugadorActual():Jugador {
			return this.chico.getJugadorEnTurno();
		}
		public function getUltimosPuntajes():Array {
			return new Array(this.getJugadorActual().getUltimosResultados(3), this.getJugadorActual().getCantidadLanzamientos());	
		}
		public function getHighScores(cuantos:int):Array {
			return this.recordsVar.getRecords();
		}
		public function getNumJugadores():int{
			return this.chico.getNumJugadores();
		}
		
		public function getPuntajeMaximo():int{
			return this.puntajeMaximo;
		}
		
		public function getMaxLanzamientos():int{
			return this.chico.getMaxLanzamientos();
		}
		
		public function setParticipantePorJugador( participantes:int):void{
			this.participantesPorJugador = participantes;
		}
		
		public function getParticipantesPorJugador():int{
			return this.participantesPorJugador;
		}
		
		public function analizarRecords():Array{
			var puntajes:Array = this.chico.getPromediosJugadores();
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
			return this.chico.getCantidadJugadoresActivos();
		}
		
		/**
		 * Se ha terminado el chico, ahora debemos revisar quien gano y quien perdio
		 */ 
		private function finDelChico():void{
			var ganadores = this.chico.getPuestos();
			
		}
		
		private function addListeners():void{
			this.chico.addEventListener(RanaEvento.RANA_ARGOLLA_INSERTADA,fireEvent);
			this.chico.addEventListener(RanaEvento.RANA_TURNO_CAMBIADO,fireEvent);
			this.chico.addEventListener(RanaEvento.RANA_PUNTAJE_CAMBIO,fireEvent);
			this.chico.addEventListener(RanaEvento.RANA_BLANQUEADO,fireEvent);
			this.chico.addEventListener(RanaEvento.RANA_JUGADOR_DESACTIVADO,fireEvent);
			this.chico.addEventListener(RanaEvento.RANA_TERMINAR_JUEGO,fireEvent);
			this.chico.addEventListener(RanaEvento.GANADOR,fireEvent);
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
					this.finDelChico();
					break;
				case RanaEvento.GANADOR:
					this.sonar("ganador");
			}
				
		}
	}
}