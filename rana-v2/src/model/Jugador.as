package model {
	
	/**
	 * Esta clase representara a un jugador de la rana, se encargara basicamente de guardar los datos
	 * de este como el puntaje, el numero, el numero de blanqueadas un historico de puntajes y si es activo o no.
	 * @author Michel Cetina
	 */
	public class Jugador {
		
		private var numero:int;
		private var puntaje:int;
		private var blanqueadas:int;
		
		/**
		 *Los puntajes quedaran ingresados en el orden que van llegando. Es decir el arreglo tendra en sus primeras posiciones los primeros
		 * puntajes y al final los ultimos puntajes ingresados
		 */
		private var puntajes:Array;
		
		/**
		 * Cuando un jugador alcanze el maximo de blanqueadas quedara como no activo. Y no podra seguir participando
		 * del juego.
		 */
		private var activo:Boolean;
		
		public function Jugador(){
			this.numero = -1;
			this.puntaje = 0;
			this.blanqueadas = 0;
			this.puntajes = new Array();
			this.activo = new Boolean(true);
		}
		
		public function getNumero():int {
			return this.numero;
		}
		public function setNumero(valor:int):void {
			this.numero = valor;
		}
		public function getBlanqueadas():int {
			return this.blanqueadas;
		}
		public function sumarBlanqueada():void {
			this.blanqueadas++;
		}
		public function getPuntajeActual():int {
			return this.puntaje;
		}
		
		/**
		 * Retorna los ultimos resultados del jugador
		 * @param cuantos	El numero de resultados a mostrar, si este valor viene en -1 retornamos todos los resultados
		 */
		public function getUltimosResultados(cuantos:int):Array {
			
			if(cuantos==-1)
				return this.puntajes;
			
			var retorno:Array = new Array();
			
			for(var i:int=this.puntajes.length-1; i>=0 && (this.puntajes.length - i  != cuantos+1) ; i--)
				retorno.push(this.puntajes[i]);
			
			return retorno;
		}
		public function desactivar():void {
			this.activo = false;
		}
		public function getEstado():Boolean {
			return this.activo;
		}
		public function getCantidadLanzamientos():int{
			return this.puntajes.length;
		}
		public function sumarPuntos(puntos:int):void{
			this.puntaje+=puntos;
			this.puntajes.push(puntos);
		}
		public function getPromedioLanzamientos():Number{
			return this.puntaje/this.puntajes.length;
		}
	}
}