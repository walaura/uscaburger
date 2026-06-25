import matplotlib.pyplot as plt
import numpy as np

# Initial values
initial_wave_speed = 3.0
initial_wave_offset = 2.0

# Parameters for the function
time_divider = 20
offset_divider = 100

# Calculate how these values change over multiple successful stacks
successful_stacks = list(range(1, 21))  # 20 successful stacks

wave_speed_values = []
wave_offset_values = []

current_wave_speed = initial_wave_speed
current_wave_offset = initial_wave_offset

for i in successful_stacks:
    wave_speed_values.append(current_wave_speed)
    wave_offset_values.append(current_wave_offset)
    
    # Apply the on_successful_stack logic
    current_wave_speed -= (current_wave_speed / time_divider)
    current_wave_offset += (current_wave_offset / offset_divider)

# Create the plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Plot wave speed over successful stacks
ax1.plot(successful_stacks, wave_speed_values, 'b-o', linewidth=2, markersize=6)
ax1.set_xlabel('Successful Stack Count')
ax1.set_ylabel('Wave Speed Timer Speed')
ax1.set_title('How Wave Speed Changes with Successful Stacks')
ax1.grid(True, alpha=0.3)

# Plot wave offset over successful stacks
ax2.plot(successful_stacks, wave_offset_values, 'r-o', linewidth=2, markersize=6)
ax2.set_xlabel('Successful Stack Count')
ax2.set_ylabel('Wave Max Offset')
ax2.set_title('How Wave Offset Changes with Successful Stacks')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('on_successful_stack_plot.png', dpi=300, bbox_inches='tight')
plt.show()

# Print final values
print(f"Final wave_speed_timer_speed: {wave_speed_values[-1]:.4f}")
print(f"Final wave_max_offset: {wave_offset_values[-1]:.4f}")