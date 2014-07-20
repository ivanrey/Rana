package  model {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import util.RanaException;

	/**
	 * Esta clase contendra la configuracion del juego.
	 * @author Michel Cetina
	 * 
	 */
	public class Configuracion{
		
		public static var cuatroC:int = 400;
		public static var ochoC:int = 800;
		public static var milDoscientos:int = 1200;
		public static var milSeiscientos:int = 1600;
		public static var milOchocientos:int = 1800;
		public static var dosMil:int = 2000;
		
		public static var individual:int = 1;
		public static var equiposDeDos:int = 2;
		public static var equiposDeTres:int = 3;
		
		public static var orificioRana:int = 11;
		public static var orificioRanita:int = 8;
		
		private var xmlFile:XML;
		public var maxBlanqueadas:int;
		/**
		 *	Un arreglo con un conjunto de posibles valores (2)
		 */
		public var maxPuntaje:Array;
		public var puntosOrificio:Array;
		public var maxFichas:int;
		public var maxRecords:int;
		
		public function Configuracion(){
			this.maxBlanqueadas = 0;
			this.maxPuntaje = new Array();
			this.puntosOrificio = new Array();
			this.maxFichas = 0;
		}
		
		public function getMaxBlanqueadas():int {
			return this.maxBlanqueadas;
		}
		public function setMaxBlanqueadas(valor:int):void {
			this.maxBlanqueadas = valor;
		}
		public function setMaxPuntaje(valor:Array):void {
			if(valor.length == 0)
				throw new RanaException("El arreglo de puntajes debe de ser mayor a cero");
			this.maxPuntaje = valor;
		}
		public function getMaxPuntaje():Array {
			return this.maxPuntaje;
		}
		public function setPuntosOrificio(puntos:Array):void {
			if(puntos.length == 0)
				throw new RanaException("El numero de orificios debe de ser mayor a cero");
			this.puntosOrificio = puntos;
		}
		public function getPuntoEnOrificio(posicion:int):int {
			if(this.puntosOrificio[posicion] == undefined)
				throw new RanaException("La posicion no existe en el arreglo de puntos para los orificios");
			return this.puntosOrificio[posicion];
		}
		public function getMaxFichas():int {
			return this.maxFichas;
		}
		public function setMaxFichas(maximo:int):void {
			if(maximo < 1)
				throw new RanaException("El numero maximo de fichas debe de ser mayor que cero");
			this.maxFichas = maximo;
		}
		public function getMaxRecords():int{
			return this.maxRecords;
		}
		public function setMaxRecords(valor:int):void{
			if(valor < 1)
				throw new RanaException("El numero de records debe de ser mayor que cero");
			this.maxRecords = valor;
		}
		public function loadConfiguracion():void{
			
			var file:File = new File("app:/assets/conf/configuracion.xml");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			this.xmlFile = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			this.setMaxBlanqueadas(xmlFile.maxblanqueadas[0]);
			this.setMaxFichas(xmlFile.maxfichas[0]);
			this.setMaxRecords(xmlFile.maxrecords[0]);
			
			for(var i:int=0; i<xmlFile.maxpuntaje.length(); i++)
				this.maxPuntaje.push(int(xmlFile.maxpuntaje[i].toString()));
			
			this.setMaxPuntaje(this.maxPuntaje);
			
			for(var j:int=0; j<xmlFile.orificio.length(); j++){
				var indice:int = this.xmlFile.orificio[j].@id;
				var valor:int = this.xmlFile.orificio[j];
				this.puntosOrificio[indice] = valor;
			}
			this.setPuntosOrificio(this.puntosOrificio);
		}
	}
}