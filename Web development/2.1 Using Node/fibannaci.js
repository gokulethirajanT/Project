function fibonacci(n) {
    let fib = [0, 1]; // Starting two numbers in Fibonacci sequence
  
    for (let i = 2; i < n; i++) {
      fib[i] = fib[i - 1] + fib[i - 2]; // Add the previous two numbers
    }
  
    return fib.slice(0, n); // Return only 'n' numbers from the sequence
  }
  
  let n = 10; // Change this value for more numbers in the sequence output
  console.log(fibonacci(n));
  
  