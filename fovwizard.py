import os
import json
import tkinter as tk
from tkinter import *
import tkinter.filedialog
#from PIL import Image, ImageTk
from io import BytesIO
import base64
import re
from tkinter import messagebox
# GUI setup
root = tk.Tk()
root.title("VRCitizen FOV Wizard")
#root.configure(bg="green")

# Disable resizing
root.resizable(False, False)

# Center the window on the screen
window_width = 500  # Set your desired window width
window_height = 600  # Set your desired window height
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()

x_position = (screen_width // 2) - (window_width // 2)
y_position = (screen_height // 2) - (window_height // 2)

root.geometry(f"{window_width}x{window_height}+{x_position}+{y_position}")

# Additional text label
#additional_text = "Very Special thanks to RifleJock for getting all the VR Headset data in one place and for the suggestions and for being an idea soundboard. Special thanks to SilvanVR at CIG and Chachi Sanchez for getting VRCitizen going. Find them both on YouTube and Twitch. See you in the 'VRse  o7 "
#label_text = Label(root, text=additional_text, font=("Arial", 12), wraplength=400, justify="center", anchor="n")
#label_text.pack(padx=10, pady=10, anchor="n")

# Get the list of available drives
import string
drives = [f"{letter}:" for letter in string.ascii_uppercase if os.path.exists(f"{letter}:\\")]

# Load headset data from the JSON file
with open('fovwizard/configs.json', 'r') as json_file:
    data = json.load(json_file)

brands = data["hmds"]

from json import load, dump

new_data = []

for key, value in data.items():
    print("Processing",key)
    new_value = value
    # new_key = [k.strip() for k in key.split("|")]
    value["Name"] = key

    # if isinstance(value["All Possible Lens Configurations"], str):
    #     value["All Possible Lens Configurations"] = [value["All Possible Lens Configurations"]]

    # if (new_value["Error Report (SC FOV Cap 120)"]) == False:
    #     del new_value["Error Report (SC FOV Cap 120)"]
    # else:
    #     val = new_value["Error Report (SC FOV Cap 120)"]
    #     del new_value["Error Report (SC FOV Cap 120)"]
    #     new_value["Notes"] = val
    # if new_value["VorpX Config Pixel 1:1 Zoom"] == -1:
    #     del new_value["VorpX Config Pixel 1:1 Zoom"]

    new_data.append(new_value)
    # new_data[key] = new_value





# Set default headset
default_brand = "Select Manufacturer"
default_headset = "Select VR Headset"
default_config = "Select Configuration"

# Label for brand selection
headset_label = tk.Label(root, text="Select VR Headset brand in the dropdown below:", anchor="c", font=("Arial", 12))
headset_label.pack(padx=10, pady=10, anchor="c")

# Dropdown for brand selection
brands_var = tk.StringVar()
brands_keys = list(brands.keys())  # Updated to get the list of headsets dynamically
brands_var.set(default_brand)
headset_dropdown = tk.OptionMenu(root, brands_var, *brands_keys)
headset_dropdown.pack(padx=10, pady=10, anchor="c")

# Label for headset selection
headset_label = tk.Label(root, text="Select VR Headset in the dropdown below \n(for PIMAX also choose lenses installed):", anchor="c", font=("Arial", 12))
headset_label.pack(padx=10, pady=10, anchor="c")

# Dropdown for headset selection
headset_var = tk.StringVar()
headset_var.set(default_headset)
headset_dropdown = tk.OptionMenu(root, headset_var, "No headsets")
headset_dropdown.pack(padx=10, pady=10, anchor="c")

# Label for lens selection
lense_label = tk.Label(root, text="Select Lense configuration in the dropdown below:", anchor="c", font=("Arial", 12))
lense_label.pack(padx=10, pady=10, anchor="c")

# Dropdown for lens selection
lense_var = tk.StringVar()
lense_var.set(default_config)
lense_dropdown = tk.OptionMenu(root, lense_var, "No configurations")
lense_dropdown.pack(padx=10, pady=10, anchor="c")

# Label for resolution selection
resolution_label = tk.Label(root, text="Select Resolution in dropdown below and then hit UPDATE:", anchor="c", font=("Arial", 12))
resolution_label.pack(padx=10, pady=10, anchor="c")

# Dropdown for resolution selection
resolution_var = tk.StringVar()
resolution_menu = tk.OptionMenu(root, resolution_var, "No Resolutions")
resolution_menu.config(font=("Arial", 12))
resolution_menu.pack(padx=10, pady=10, anchor="c")

def update_brand_data(*args):
    selected_brand = brands_var.get()
    if not selected_brand: return
    headset_dropdown['menu'].delete(0, 'end')  # Clear the existing menu
    for hmd in brands[selected_brand].keys():
        headset_dropdown['menu'].add_command(label=hmd, command=tk._setit(headset_var, hmd))
    headset_var.set(list(brands[selected_brand].keys())[0])

# Bind the update function to the brand dropdown
brands_var.trace_add("write", lambda *args: update_brand_data(*args))

def update_lens_data(*args):
    selected_brand = brands_var.get()
    if not selected_brand: return
    selected_headset = headset_var.get()
    if not selected_headset: return
    lense_dropdown['menu'].delete(0, 'end')  # Clear the existing menu
    keys = brands[selected_brand][selected_headset].keys()
    for config in keys:
        lense_dropdown['menu'].add_command(label=config, command=tk._setit(lense_var, config))
    lense_var.set(list(brands[selected_brand][selected_headset].keys())[0])

# Bind the update function to the brand dropdown
headset_var.trace_add("write", lambda *args: update_lens_data(*args))

def get_selections():
    return brands_var.get(), headset_var.get(), lense_var.get(), resolution_var.get()

def get_selected_data():
    return brands[brands_var.get()][headset_var.get()][lense_var.get()]

# Update FOV and resolutions based on the selected headset
def update_headset_data(fov_var, *args):
    selected_headset = get_selected_data()
    if selected_headset:
        # Fetch FOV and clamp it to a maximum of 120
        fov_value = min(selected_headset.get("SC Attributes FOV", 0), 120)
        fov_var.set(fov_value)

        # Fetch resolutions and update the dropdown
        custom_resolutions = selected_headset.get("Custom Resolution List", [])
        resolution_menu['menu'].delete(0, 'end')  # Clear the existing menu

        for resolution in custom_resolutions:
            resolution_menu['menu'].add_command(label=resolution, command=tk._setit(resolution_var, resolution))

        if custom_resolutions:
            resolution_var.set(custom_resolutions[0])
        else:
            resolution_var.set("No Resolutions")

# Bind the update function to the headset dropdown
lense_var.trace_add("write", lambda *args: update_headset_data(fov_var, *args))
fov_var = tk.DoubleVar()
    
def on_update():
    try:
        selected_data = get_selected_data()
        fov = fov_var.get()
        fov = round(fov)
        resolution = resolution_var.get()
        
        # Ensure resolution is valid and parse it into width and height
        match = re.match(r"^(\d+)\s*[xX]\s*(\d+)", resolution)
        if match:
            width, height = map(int, match.groups())
        else:
            messagebox.showerror("Error", "Invalid resolution selected. Please choose a valid resolution.")
            return
        
        # Format the output as a string
        clipboard_output = f"FOV: {fov}\nWidth: {width}\nHeight: {height}"
        print(clipboard_output)
        
        # Copy the output directly to the clipboard
        root.clipboard_clear()
        root.clipboard_append(clipboard_output)
        root.update()  # Update the clipboard
        
        # Show a success message
        #messagebox.showinfo("Success", "The FOV, width, and height have been copied to the clipboard.")
        root.after(10, root.quit)
    except Exception as e:
        messagebox.showerror("Error", f"Failed to update: {e}")
 

# Add the Update button
update_button = tk.Button(root, text="Update", command=on_update, font=("Arial", 12))
update_button.pack(padx=10, pady=20, anchor="c")
     


# Run the Tkinter event loop
root.mainloop()