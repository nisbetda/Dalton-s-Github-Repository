package loop;

public class Unrolled {

	public static void main(String[] args) {
		//create array of length 100
		int length = 100000000;
		int[] array = new int[length];
		
		//loop body enters 10 numbers into 10 array positions at once
		//loop iterates only 10 times 
		//to input a random number between 1 and 100
		//into an array called array
		for(int i = 0; i < length; i+=10) {
			array[i] = (int)(Math.random() * 100) + 1; 
			array[i+1] = (int)(Math.random() * 100) + 1; 
			array[i+2] = (int)(Math.random() * 100) + 1; 
			array[i+3] = (int)(Math.random() * 100) + 1; 
			array[i+4] = (int)(Math.random() * 100) + 1; 
			array[i+5] = (int)(Math.random() * 100) + 1; 
			array[i+6] = (int)(Math.random() * 100) + 1; 
			array[i+7] = (int)(Math.random() * 100) + 1; 
			array[i+8] = (int)(Math.random() * 100) + 1; 
			array[i+9] = (int)(Math.random() * 100) + 1; 

		
		}


	}

}
