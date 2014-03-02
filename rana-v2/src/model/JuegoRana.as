package model {
	import flash.events.EventDispatcher;
	
	import util.RanaException;

	public class JuegoRana extends EventDispatcher{
		
		private var numJugadores:int;
		private var puntajeMaximo:int;
		private var turno:int;
		private var jugadores:Array;
		private var puntajeTurno:int;
		private var puntajesTurno:Array;
		private var configuracion:Configuracion;
		private var maxLanzamientos:int;
		
		public function JuegoRana(configuracion:Configuracion){
			this.numJugadores = 0;
			this.puntajeMaximo = 0;
			this.turno = -1;
			this.jugadores = new Array();
			this.puntajesTurno = new Array();
			this.puntajeTurno = 0;
			this.configuracion = configuracion;
		}
		
		public function setNumJugadores(valor:int):void {
			if(valor < 1)
				throw new RanaException("El numero de jugadores debe de ser mayor a cero");
			this.numJugadores = valor;
		}
		
		public function getNumJugadores():int {
			return this.numJugadores;
		}
		
		public function getTurno():int{
			return this.turno;
		}
		
		public function getPuntajeMaximo():int {
			return this.puntajeMaximo;
		}
		
		public function setPuntajeMaximo(valor:int):void {
			if(valor < 1)
				throw new RanaException("El puntaje maximo debe de ser mayor a cero");
			this.puntajeMaximo = valor;
		}
		
		public function setParticipantesPorJugador( participantes:int ):void{
			this.maxLanzamientos = 6;//participantes * 6; //cada participante tiene 6 lanzamientos
		}
		
		public function iniciarJuego():void {
			if(this.numJugadores < 1)
				throw new RanaException("El numero de jugadores debe de ser mayor a cero");
			if(this.puntajeMaximo < 1)
				throw new RanaException("El puntaje maximo debe de ser mayor a cero");
			
			this.turno = 1;
			for(var i:int=0; i<this.numJugadores; i++){
				var jugador:Jugador = new Jugador();
				jugador.setNumero(i+1);
				jugadores[i] = jugador;
			}
		}

		public function registrarLanzamiento(orificio:int):void {
			
			var jugador:Jugador = this.getJugadorEnTurno();
			// Verificamos que no se hayan registrado mas de maxLanzamientos lanzamientos
			if(this.puntajesTurno.length >= this.maxLanzamientos || !jugador.getEstado())
				return;
			
			var puntaje:int = configuracion.getPuntoEnOrificio(orificio);			
			
			this.puntajeTurno = Math.min(this.puntajeMaximo,this.puntajeTurno + puntaje);
			
			this.puntajesTurno.push(puntaje);
			
			dispatchEvent(new RanaEvento(RanaEvento.RANA_ARGOLLA_INSERTADA,new Array(puntaje,this.puntajeTurno,orificio)));
			
			// Verificamos si el jugador actual gano
			if(jugador.getPuntajeActual() + this.puntajeTurno >= this.puntajeMaximo){
				jugador.sumarPuntos(this.puntajeTurno,this.puntajeMaximo);
				dispatchEvent(new RanaEvento(RanaEvento.GANADOR, new Array(puntaje, this.puntajeTurno, orificio, this.puntajeMaximo, jugador)));
			}
			
			
		}
		
		public function getJugadorEnTurno():Jugador{
			return this.jugadores[this.turno-1];
		}
		
		public function getMaxLanzamientos():int{
			return this.maxLanzamientos;
		}
		
		/**
		 * 
		 * @param nuevoTurno	Un numero entre 1 y el numero de jugadores
		 */
		public function cambiarTurno(nuevoTurno:int):void {
			// Verificamos que el nuevo turno conincida con el siguiente turno en el juego
			var encontro:Boolean = false;
			var turnoTemp:int;
			for(var i:int=(this.turno+1)%this.numJugadores; (i!=this.turno) && !encontro ; i=(i+1)%this.numJugadores){
				i = i==0 ? this.numJugadores : i;
				if(jugadores[i-1].getEstado()){
					encontro = true;
					turnoTemp = i;
				}
			}
			
			//nuevoTurno = turnoTemp;	// Saltandome el ingreso del turno
			
			if(nuevoTurno!=turnoTemp)
				throw new RanaException("Verifique el turno ingresado, ya que no correspone con el siguiente turno",RanaException.TURNO_INVALIDO);
			
			// 	Verificamos que el jugador no se haya ido blanqueado
			var jugador:Jugador = this.getJugadorEnTurno();
			if(this.puntajeTurno == 0){
				jugador.sumarBlanqueada();
				dispatchEvent(new RanaEvento(RanaEvento.RANA_BLANQUEADO,new Array(this.turno,jugador.getBlanqueadas())));
				// Enviar evento a la fachada
				if(jugador.getBlanqueadas() == configuracion.getMaxBlanqueadas()){
					jugador.desactivar();
					dispatchEvent(new RanaEvento(RanaEvento.RANA_JUGADOR_DESACTIVADO, this.turno));	
				}
				this.puntajeTurno = -10;
			}
			jugador.sumarPuntos(this.puntajeTurno, this.puntajeMaximo);
			dispatchEvent(new RanaEvento(RanaEvento.RANA_PUNTAJE_CAMBIO, new Array(this.turno,jugador.getPuntajeActual())));
			
			// 	Calculamos el proximo turno (Hay que tener en cuenta los jugadores que ya no estan activos 
			//	por que se fueron blanqueados demasiadas veces, puede ser que todos esten blanqueados y en 
			//  este caso )
			this.asignarProximoTurno(nuevoTurno);
		}
		/** 
		 * Este metodo sera lanzado una vez todos menos uno de los jugadores alcanze o supere el puntaje maximo.
		 * Internamente se calculara si uno de los participantes obtuvo un nuevo record en la rana.
		 */
		public function finalizarJuego(tipo:String):void {			
			dispatchEvent(new RanaEvento(RanaEvento.RANA_TERMINAR_JUEGO,tipo));
		}
		
		public function asignarProximoTurno(nuevoTurno:int):void{
			this.turno = nuevoTurno;
			var jugador:Jugador = this.getJugadorEnTurno();
			// Si el jugador en turno no esta activo queire decir que era el ultimo que quedaba jugando y cumplio el maximo de
			// turnos blanqueados, por lo tanto es necesario terminar el juego
			if(!jugador.getEstado())
				this.finalizarJuego(RanaEvento.FIN_JUEGO_BLANQUEADO);
				
			this.puntajeTurno = 0;
			this.puntajesTurno = new Array();
			dispatchEvent(new RanaEvento(RanaEvento.RANA_TURNO_CAMBIADO,this.turno));
		}
		
		public function getResultadoJugadores():Array{
			var resultados:Array = new Array();
			for each(var jugador:Jugador in this.jugadores){
				var puntaje:int = jugador.getPuntajeActual();
				var numero:int = jugador.getNumero();
				resultados.push(new Array(numero,puntaje));
			}
			return resultados;
		}
		
		public function getPromediosJugadores():Array{
			var retorno:Array = new Array()
			for each(var jugador:Jugador in this.jugadores)
				retorno.push(new Array(jugador.getNumero(),jugador.getPromedioLanzamientos()));
			return retorno;
		}
		
		public function getCantidadJugadoresActivos():int{
			var numJugadoresActivos:int = 0;
			for each(var jugador:Jugador in this.jugadores)
				if(jugador.getEstado())
					numJugadoresActivos++;
			return numJugadoresActivos;
			
		}
	}
}