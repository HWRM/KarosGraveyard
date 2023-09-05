-- somehow import Vec3...

-- define vectors v1 and v2, and a number n
local v1 = Vec3({ 1, 5, 2 });
local v2 = Vec3({ 10, -2, -6 });
local n = 5;

print("v1: " .. v1);
print("v2: " .. v2);
print("n: " .. n);
print("---\n");

print("v1 + v2 = " .. v1 + v2);
print("v2 + v1 = " .. v2 + v1);
print("v1 + n = " .. v1 + n);
print("n + v2 = " .. n + v2);
print("---\n");

print("v1 - v2 = " .. v1 - v2);
print("v2 - v1 = " .. v2 - v1);
print("v1 - n = " .. v1 - n);
print("n - v2 = " .. n - v2);
print("---\n");

print("v1 * n = " .. v1 * n);
print("n * v2 = " .. n * v2);
print("error on v1 * v2: " .. tostring(v1 * v2));
print("---\n");

print("v1 / n = " .. v1 / n);
print("n / v2 = " .. n / v2);
print("error on v1 / v2: " .. tostring(v1 / v2));
print("---\n");

print("v1 ^ n = " .. v1 ^ n);
-- lua doesn't seem to allow this
-- print("n ^ v2 = " .. n ^ v2);
print("---\n");

print("v1 * v2 (dot) = " .. Vec3:dot(v1, v2));
print("v1 x v2 (cross) = " .. Vec3:cross(v1, v2));
