-- ========================================================================
-- Vec3.lua: Utils & syntax sugar for using 3-d vector tables.
-- ---
-- Author: Fear (Novaras; tfear091@gmail.com)
-- ---
-- A 'Vec3' is just a Lua table with only three values on the keys
-- [1], [2], and [3]. Tag methods are set to cause access to the keys
-- 'x', 'y', and 'z' to alias the real number keys.
-- Tag methods are also set to allow you to work with Vec3s with math
-- operators like +, -, *, /, and some utils are provided on the static
-- Vec3 table such as 'magnitude', 'cross' (product), 'dot' (product).
-- Finally, a tag method is set to allow Vec3 to be castable to string,
-- so you can concat your vectors for printing etc.
-- ========================================================================

-- util function checking if the given table has the given key
function includesKey(table, value)
	for i, v in table do
		if i == value then
			return 1;
		end
	end
end

---@class Vec3
---@field [1] number
---@field [2] number
---@field [3] number
---@field x number
---@field y number
---@field z number
---@operator unm: Vec3
---@operator add(Vec3): Vec3
---@operator sub(Vec3): Vec3
---@operator mul(Vec3): Vec3
---@operator div(Vec3): Vec3
---@operator pow: Vec3

---@alias Vec3Like Vec3

---@class Vec3Static
---@operator call(Vec3Like): Vec3
Vec3 = {
	_key_mappings = {
		1,
		2,
		3,
	};
};
Vec3._key_mappings['x'] = 1;
Vec3._key_mappings['y'] = 2;
Vec3._key_mappings['z'] = 3;

---@param t any
---@return bool
function Vec3:isVec3(t)
	if (not t) then return nil; end
	if (type(t) ~= "table") then return nil; end

	for k, _ in t do
		local is_valid = includesKey(Vec3._key_mappings, k);
		if (not is_valid) then return nil; end
	end

	return 1;
end

---@param init Vec3Like|number
---@return Vec3
function Vec3:create(init)
	init = init or {};
	if (type(init) == "number") then
		---@diagnostic disable-next-line
		init = { init, init, init };
	end

	local new_vec = {};
	for i = 1, 3 do
		new_vec[i] = init[i] or 0;
	end

	-- === TAG SETUP === --
	local vector_tag = newtag();

	-- === Math Operators ===
	local unm_hook = function (v1)
		local negation = {};
		for k, _ in v1 do
			negation[k] = -v1[k];
		end
		return Vec3(negation);
	end
	settagmethod(vector_tag, "unm", unm_hook);

	local add_hook = function (lh, rh, o)
		lh = Vec3(lh);
		rh = Vec3(rh);

		local sum = {};
		for k, _ in lh do
			sum[k] = lh[k] + rh[k];
		end
		return Vec3(sum);
	end
	settagmethod(vector_tag, "add", add_hook);

	local sub_hook = function (lh, rh)
		lh = Vec3(lh);
		rh = Vec3(rh);

		local sum = {};
		for k, _ in lh do
			sum[k] = lh[k] - rh[k];
		end
		return Vec3(sum);
	end
	settagmethod(vector_tag, "sub", sub_hook);

	local scalar_mul_hook = function (lh, rh)
		if (type(lh) ~= "number" and type(rh) ~= "number") then -- trying to multiply a Vec3 with a non-number if neither operand is a number
			print("ERROR: Tried to multiply a Vec3 with a non-numeric type:");
			print("\tlh = " .. tostring(lh) .. ", of type '" .. type(lh) .. "'");
			print("\trh = " .. tostring(rh) .. ", of type '" .. type(rh) .. "'");
			return nil;
		end

		lh = Vec3(lh);
		rh = Vec3(rh);

		local prod = {};
		for k, _ in lh do
			prod[k] = lh[k] * rh[k];
		end
		return Vec3(prod);
	end
	settagmethod(vector_tag, "mul", scalar_mul_hook);

	local scalar_div_hook = function (lh, rh)
		if (type(lh) ~= "number" and type(rh) ~= "number") then -- trying to divide a Vec3 with a non-number if neither operand is a number
			print("ERROR: Tried to divide a Vec3 with a non-numeric type:");
			print("\tlh = " .. tostring(lh) .. ", of type '" .. type(lh) .. "'");
			print("\trh = " .. tostring(rh) .. ", of type '" .. type(rh) .. "'");
			return nil;
		end

		lh = Vec3(lh);
		rh = Vec3(rh);

		local prod = {};
		for k, _ in lh do
			prod[k] = lh[k] / rh[k];
		end
		return Vec3(prod);
	end
	settagmethod(vector_tag, "div", scalar_div_hook);

	local pow_hook = function(lh, rh)
		lh = Vec3(lh);
		rh = Vec3(rh);

		local prod = {};
		for k, _ in lh do
			prod[k] = lh[k] ^ rh[k];
		end
		return Vec3(prod);
	end
	settagmethod(vector_tag, "pow", pow_hook);


	local concat_hook = function (lh, rh)
		return Vec3:toStr(lh) .. Vec3:toStr(rh);
	end
	settagmethod(vector_tag, "concat", concat_hook);


	--- Helper

	--- === Prevent setting other keys, & maps sets on x, y, z to the number keys ===

	local settable_protect_hook = function (tbl, key, val)
		local mapped = Vec3._key_mappings[key];

		if (not mapped) then
			return nil;
		end

		rawset(tbl, mapped, val);
	end
	settagmethod(vector_tag, "settable", settable_protect_hook);

	--- === Special behavior when accessing keys x, y, and z ===

	local gettable_hook = function (tbl, key)
		local mapped = Vec3._key_mappings[key];

		if (not mapped) then
			return nil;
		end

		return rawget(tbl, mapped);
	end
	settagmethod(vector_tag, "gettable", gettable_hook);

	-- === Set the tag on the vector table ===
	settag(new_vec, vector_tag);

	return new_vec;
end

--- Returns the unit vector of the given vector.
---
---@param vec3 Vec3Like
---@return number
function Vec3:unit(vec3)
	vec3 = Vec3(vec3);
	return vec3 / Vec3:mag(vec3);
end

--- Returns a vector where each element is the absolute value of the corresponding element in `vec3`.
---
---@param vec3 Vec3Like
---@return Vec3
function Vec3:abs(vec3)
	vec3 = Vec3(vec3);
	local abs = {};
	for k, _ in vec3 do
		abs[k] = abs(vec3[k]);
	end
	return Vec3(abs);
end

--- Returns the mangitude of the given vector.
---
---@param vec3 Vec3Like
---@return number
function Vec3:magnitude(vec3)
	vec3 = Vec3(vec3);
	local mag = 0;
	for _, v in vec3 do
		mag = mag + (v ^ 2);
	end
	return sqrt(mag);
end

---@see Vec3.magnitude
function Vec3:mag(vec3)
	return Vec3:magnitude(vec3);
end

--- Returns the angle between v1 and v2, in radians.
---
--- This is a pretty expensive operation.
---
---@param v1 Vec3Like
---@param v2 Vec3Like
---@return number
function Vec3:angleBetween(v1, v2)
	return acos(Vec3:dot(v1, v2) / (Vec3:mag(v1) * Vec3:mag(v2)));
end

--- Returns the dot product (scalar product) of the given vectors.
---
---@param v1 Vec3Like
---@param v2 Vec3Like
---@return number
function Vec3:dot(v1, v2)
	v1 = Vec3(v1);
	v2 = Vec3(v2);

	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
end

---@see Vec3.dot
function Vec3:scalarProd(v1, v2)
	return Vec3:dot(v1, v2);
end

--- Returns the cross product (vector product) of the given vectors.
---
---@param v1 Vec3Like
---@param v2 Vec3Like
---@return Vec3
function Vec3:cross(v1, v2)
	v1 = Vec3(v1);
	v2 = Vec3(v2);

	-- { x: (aybz - azby), y: (azbx - axbz), z: (axby - aybx) }

	return Vec3({
		[1] = (v1.y * v2.z) - (v1.z * v2.y),
		[2] = (v1.z * v2.x) - (v1.x * v2.z),
		[3] = (v1.x * v2.y) - (v1.y * v2.x)
	});
end

---@see Vec3.cross
function Vec3:vectorProd(v1, v2)
	return Vec3:cross(v1, v2);
end

--- Converts a `Vec3` to a string representation. If `val` is any other type, `tostring` is used instead.
---
---@param val any
---@return string
function Vec3:toStr(val)
	if (not Vec3:isVec3(val)) then -- if something other than a vec3, return normal tostring
		return tostring(val);
	end
	---@cast val Vec3

	local v_str = "";
	for k, v in val do
		v_str = "" .. v_str .. "[" .. k .. "]: " .. tostring(v) .. ", ";
	end
	return "{ " .. v_str .. "}";
end

-- === Here we allow the `vec3` table to be called like a constructor fn i.e "`local v = Vec3(...)`" ===
vec3_tag = newtag();
vec3_fn_call_hook = function (fn, ...)
	---@diagnostic disable-next-line
	return Vec3:create(arg[1]);
end
settagmethod(vec3_tag, "function", vec3_fn_call_hook);
settag(Vec3, vec3_tag);
