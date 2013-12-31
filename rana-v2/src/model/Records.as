package  model {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;

	public class Records {
		public var xmlData:XML;
		private var file:File;
		private var fileStream:FileStream;
		public var maxRecords:int;
		/**
		 *	Este arreglo contendra una serie de arreglos con la siguiente estructura:
		 * 		["nombre"]	=>	Nombre de la persona que hizo el record
		 * 		["record"]	=>	El valor del record (int)
		 * 
		 * 	El arreglo estara ordenando ascendentemete, es decir el mejor record se ubicara
		 * 	en la primera posicion del arreglo y el peor record se ubicara en la ultima posicion 
		 */
		public var recordsArr:Array;
		
		public function Records(conf:Configuracion):void{
			this.recordsArr = new Array();
			this.maxRecords = conf.getMaxRecords();
			this.file = File.userDirectory.resolvePath("records.xml");
			if(!this.file.exists){
				var fileTemp:File = new File("app:/assets/records/records.xml");
				fileTemp.copyTo(this.file,false);
			}
			this.loadRecords();
		}
		
		public function calcularPuntaje(puntajes:Array):int {
			var total:int = 0;
			for each(var puntaje:int in puntajes)
				total+=puntaje;
			return total/puntajes.length();
		}
		
		public function getRecords():Array{
			return this.recordsArr;
		}
		
		/**
		 * Este metodo compara si el nuevo puntaje califica como un nuevo record
		 * @param punatje	El puntaje a comparar con los records
		 * @return  
		 */
		public function analizarRecord(punatje:int):Boolean {	
			return (this.recordsArr.length < maxRecords) || (punatje > this.recordsArr[this.recordsArr.length-1]["record"]) ? true : false;
		}
		
		/**
		 * Este metodo sera llamada unicamente por la interfaz y tendra como precondicion que el record ya ha sido analizado. El
		 * nuevo record sera salvado en memoria y a la vez sobreescribira el archivo xml
		 * @param record
		 * @param nombre 
		 */
		public function ingresarRecord(record:int, nombre:String):void {
			var nuevoRecord:Array = new Array();
			nuevoRecord["nombre"] = nombre;
			nuevoRecord["record"] = record;
			this.insertarRecord(nuevoRecord,true);
		}
		
		/***
		 * TODO: Aca se deberia hacer 
		 * */
		
		public function loadRecords():void{
			this.abrirArchivo(FileMode.READ);
			this.xmlData = new XML(this.fileStream.readUTFBytes(this.fileStream.bytesAvailable));
			for(var i:int=0; i<this.xmlData.record.length(); i++){
				var record:Array = new Array();
				record["nombre"] = new String(this.xmlData.record[i].@nombre);
				record["record"] = int(this.xmlData.record[i].@record)
				this.insertarRecord(record);
			}
			this.cerrarArchivo();
		}
		
		/**
		 * Una precondicion en este metodo es que el arreglo de records se encuentra ordenado en un orden
		 * ascendente
		 * @param record	El nuevo record a insertar
		 * @param salvar 	Este parametro señalara si se desea salvar el record en el archivo xml de records
		 */
		private function insertarRecord(record:Array, salvar:Boolean = false):void{
			if(this.recordsArr.length == 0)
				this.recordsArr.push(record);
			else{
				var encontro:Boolean = false;
				for(var i:int=0; i<this.recordsArr.length&&!encontro; i++){
					if(record["record"]>=this.recordsArr[i]["record"]){
						this.insertarRecordEnArreglo(i,record);
						encontro = true;
					}
				}
				
				if(!encontro)
					this.recordsArr.push(record);
			}
			
			if(this.recordsArr.length > this.maxRecords)
				this.recordsArr = this.recordsArr.slice(0,this.maxRecords);
			
			if(salvar){
				this.abrirArchivo(FileMode.WRITE);
				this.fileStream.writeUTFBytes('<?xml version="1.0" ?>\n<records>\n');
				for(var j:int=0; j<this.recordsArr.length; j++) 
					this.fileStream.writeUTFBytes('\t<record nombre="'+this.recordsArr[j]["nombre"]+'" record="'+this.recordsArr[j]["record"]+'" ></record>\n');
				this.fileStream.writeUTFBytes('</records>');
				this.cerrarArchivo();
			}
		}
		
		private function abrirArchivo(fileMode:String):void{
			this.fileStream = new FileStream();
			this.fileStream.open(this.file,fileMode);
		}
		
		private function cerrarArchivo():void{
			this.fileStream.close();
		}
		
		private function insertarRecordEnArreglo(index:int, value:Array):void{
			var original:Array = this.recordsArr.slice(); // a, c, d
			var temp:Array = original.splice(index); // c, d
			original[index] = value; // b
			original = original.concat(temp); // a, b, c, d
			this.recordsArr = original;
		}
	}
}