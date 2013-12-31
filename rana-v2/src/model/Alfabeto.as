package model
{
	public class Alfabeto
	{
		private var letras:Array;
		
		public function Alfabeto(){
			letras = new Array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
		}
		
		public function getLetraAt(index:int):String{
			return this.letras[index];
		}
	}
}