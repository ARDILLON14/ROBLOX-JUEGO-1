--!strict
--[[
	RateLimiter
	Limita cuántas veces por segundo puede hacer algo cada jugador
	(técnica "cubo de fichas": el cubo se rellena con el tiempo y cada acción gasta una ficha).
]]

export type RateLimiter = {
	allow: (player: Player) -> boolean,
	remove: (player: Player) -> (),
}

type Bucket = {
	tokens: number,
	lastTime: number,
}

local RateLimiter = {}

function RateLimiter.new(maxPerSecond: number): RateLimiter
	assert(maxPerSecond > 0, "maxPerSecond debe ser mayor que 0")
	local buckets: { [Player]: Bucket } = {}

	local function allow(player: Player): boolean
		local now = os.clock()
		local bucket = buckets[player]
		if not bucket then
			bucket = { tokens = maxPerSecond, lastTime = now }
			buckets[player] = bucket
		end
		bucket.tokens = math.min(maxPerSecond, bucket.tokens + (now - bucket.lastTime) * maxPerSecond)
		bucket.lastTime = now
		if bucket.tokens >= 1 then
			bucket.tokens -= 1
			return true
		end
		return false
	end

	local function remove(player: Player)
		buckets[player] = nil
	end

	return { allow = allow, remove = remove }
end

return RateLimiter
