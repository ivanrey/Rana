package util
{
	public class RanaException extends Error
	{
		
		public static const TURNO_INVALIDO:int = 1;
		
		public function RanaException(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}