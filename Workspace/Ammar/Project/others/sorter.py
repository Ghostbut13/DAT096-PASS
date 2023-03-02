def bubbleSort(arr):
    n = len(arr)
  
    # Go through all array elements
    for i in range(n):
  
        # Last i elements are already in place
        for j in range(0, n-i-1):
  
            # traverse the array from 0 to n-i-1
            # Swap if the element found is greater
            # than the next element
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
  
  
# Driver code to test above
if __name__ == "__main__":
  arr = [5, 1, 1, 222, 8]
  
  bubbleSort(arr)
  print(arr)
 # print("Sorted array is:")
 # for i in range(len(arr)):
  #    print("%d" % arr[i], end=" ")