package loop;

public class Loop {

	public static void main(String[] args) {
		//create array of length 100
		int length = 100000000;
		int[] array = new int[length];
		
		//loop that iterates 100 times 
		//to input a random number between 1 and 100
		//into an array called array
		for(int i = 0; i < length; i++) {
			array[i] = (int)(Math.random() * 100) + 1; 
			//System.out.println(i + ": " + array[i]);
		}

	}

}
