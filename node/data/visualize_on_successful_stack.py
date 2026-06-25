#!/usr/bin/env python3

# Script to visualize 100 consecutive on_successful_stack() calls

# Constants based on the resource file
DROP_TIMEOUT = .5
WAVE_MAX_OFFSET = 2.
WAVE_SPEED_TIMER_SPEED = 3.
WAVE_TIMER_MIN_SPEED = .2

# Parameters for the function
TIME_DIVIDER = 20
OFFSET_DIVIDER = 100

def on_successful_stack(wave_speed, wave_offset):
    """Apply the on_successful_stack logic"""
    # bigger number = easier
    time_divider = TIME_DIVIDER
    offset_divider = OFFSET_DIVIDER
    
    # Apply the new formula from the updated resource file
    new_wave_speed = (
        wave_speed
        - ((wave_speed - WAVE_TIMER_MIN_SPEED) / time_divider)
        + WAVE_TIMER_MIN_SPEED
    )
    new_wave_offset = wave_offset + (wave_offset / offset_divider)
    
    return new_wave_speed, new_wave_offset

def main():
    print("DifficultyNumbersResource Visualization")
    print("=======================================")
    print()
    
    # Initial values
    wave_speed = WAVE_SPEED_TIMER_SPEED
    wave_offset = WAVE_MAX_OFFSET
    
    print(f"Initial state:")
    print(f"Wave speed timer: {wave_speed:.6f}")
    print(f"Wave max offset: {wave_offset:.6f}")
    print()
    
    # Print header
    print("Executing 100 consecutive on_successful_stack() calls:")
    print("--------------------------------------------------------")
    print("Stack | Wave Speed Timer | Wave Max Offset")
    print("--------|------------------|---------------")
    
    # Print initial state
    print("%5d | %16.6f | %13.6f" % [0, wave_speed, wave_offset])
    
    # Execute 100 calls
    for i in range(1, 101):
        wave_speed, wave_offset = on_successful_stack(wave_speed, wave_offset)
        
        if i <= 10 or i % 10 == 0:  # Print first 10 and every 10th
            print("%5d | %16.6f | %13.6f" % [i, wave_speed, wave_offset])
    
    print("--------------------------------------------------------")
    print(f"Final values after 100 calls:")
    print(f"Wave speed timer: {wave_speed:.6f}")
    print(f"Wave max offset: {wave_offset:.6f}")
    print()
    print("Analysis:")
    print(f"- Wave speed timer approaches minimum value of {WAVE_TIMER_MIN_SPEED:.2f}")
    print("- Wave max offset increases exponentially")

if __name__ == "__main__":
    main()