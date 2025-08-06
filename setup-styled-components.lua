-- Setup script for styled-components support
-- Run this in your project directory to install necessary packages

local function run_command(cmd)
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result
    end
    return nil
end

print("Setting up styled-components support...")

-- Check if package.json exists
local package_json = io.open("package.json", "r")
if not package_json then
    print("❌ No package.json found. Please run this script in your project directory.")
    return
end
package_json:close()

-- Install necessary packages
local packages = {
    "typescript-styled-plugin",
    "@types/styled-components",
    "styled-components"
}

for _, package in ipairs(packages) do
    print("Installing " .. package .. "...")
    local result = run_command("npm install --save-dev " .. package)
    if result then
        print("✅ " .. package .. " installed successfully")
    else
        print("❌ Failed to install " .. package)
    end
end

print("\n🎉 Styled-components setup complete!")
print("Restart Neovim and try typing in a styled-components template literal.")
print("You should now see CSS property suggestions!") 