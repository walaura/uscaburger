# Analysis of on_successful_stack function behavior

# Initial values based on the resource file
initial_wave_speed = 3.0
initial_wave_offset = 2.0

# Parameters from the function
time_divider = 20
offset_divider = 100

print("Analysis of on_successful_stack() function:")
print("=====================================")
print(f"Initial values: wave_speed_timer_speed = {initial_wave_speed}, wave_max_offset = {initial_wave_offset}")
print()

# Calculate how these values change over multiple successful stacks
successful_stacks = list(range(1, 110))  # First 10 successful stacks

wave_speed_values = []
wave_offset_values = []

current_wave_speed = initial_wave_speed
current_wave_offset = initial_wave_offset

print("Step-by-step changes:")
print("Stack | Wave Speed | Wave Offset")
print("-----|------------|-----------")

for i in successful_stacks:
    wave_speed_values.append(current_wave_speed)
    wave_offset_values.append(current_wave_offset)
    
    print(f"{i:5d} | {current_wave_speed:8.4f} | {current_wave_offset:9.4f}")
    
    # Apply the on_successful_stack logic
    current_wave_speed -= (current_wave_speed / time_divider)
    current_wave_offset += (current_wave_offset / offset_divider)

print()
print("Summary:")
print(f"Final wave_speed_timer_speed: {wave_speed_values[-1]:.6f}")
print(f"Final wave_max_offset: {wave_offset_values[-1]:.6f}")

# Show the mathematical pattern
print()
print("Mathematical behavior:")
print("Wave speed decreases by a factor of 1/20 each time")
print("Wave offset increases by a factor of 1/100 each time")