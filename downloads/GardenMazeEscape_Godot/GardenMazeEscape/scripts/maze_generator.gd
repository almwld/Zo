## maze_generator.gd
## مولّد المتاهة - يدعم خمس خوارزميات مختلفة
## Maze Generator - supports 5 different algorithms

extends Node
class_name MazeGenerator

# ============================
# CELL CONSTANTS / ثوابت الخلايا
# ============================
## كل خلية تُمثَّل بعدد صحيح (بت ماسك لكل جدار)
const WALL_NORTH := 1  # شمال
const WALL_EAST  := 2  # شرق
const WALL_SOUTH := 4  # جنوب
const WALL_WEST  := 8  # غرب
const VISITED    := 16 # زيارة

# الاتجاهات - Directions
const DIRECTIONS := [
	Vector2i(0, -1),  # شمال
	Vector2i(1,  0),  # شرق
	Vector2i(0,  1),  # جنوب
	Vector2i(-1, 0)   # غرب
]
const DIR_WALLS := [WALL_NORTH, WALL_EAST, WALL_SOUTH, WALL_WEST]
const OPP_WALLS := [WALL_SOUTH, WALL_WEST, WALL_NORTH, WALL_EAST]

# ============================
# SIGNALS / الإشارات
# ============================
signal maze_generated(grid: Array)

# ============================
# PROPERTIES / الخصائص
# ============================
var width: int = 25
var height: int = 25
var grid: Array = []  # مصفوفة ثنائية الأبعاد [x][y]
var algorithm: int = DifficultyCurve.MazeAlgorithm.RECURSIVE_BACKTRACKER
var rng := RandomNumberGenerator.new()
var seed_value: int = 0

# ============================
# MAIN GENERATION / التوليد الرئيسي
# ============================

func generate(w: int, h: int, algo: int, level_seed: int = 0) -> Array:
	## توليد متاهة بالأبعاد والخوارزمية المحددة
	width = w
	height = h
	algorithm = algo
	seed_value = level_seed if level_seed != 0 else randi()
	rng.seed = seed_value
	
	_initialize_grid()
	
	match algorithm:
		DifficultyCurve.MazeAlgorithm.RECURSIVE_BACKTRACKER:
			_recursive_backtracker(0, 0)
		DifficultyCurve.MazeAlgorithm.PRIMS:
			_prims_algorithm()
		DifficultyCurve.MazeAlgorithm.ELLERS:
			_ellers_algorithm()
		DifficultyCurve.MazeAlgorithm.GROWING_TREE:
			_growing_tree()
		DifficultyCurve.MazeAlgorithm.ALDOUS_BRODER_WILSON:
			_aldous_broder_wilson()
	
	emit_signal("maze_generated", grid)
	return grid

func _initialize_grid() -> void:
	## تهيئة الشبكة بجميع الجدران مغلقة
	grid = []
	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(WALL_NORTH | WALL_EAST | WALL_SOUTH | WALL_WEST)

# ============================
# ALGORITHM 1: RECURSIVE BACKTRACKER / عودة التراجع التكرارية
# ============================

func _recursive_backtracker(start_x: int, start_y: int) -> void:
	## أبسط خوارزمية وتنتج متاهات طويلة الممرات
	var stack := [Vector2i(start_x, start_y)]
	grid[start_x][start_y] |= VISITED
	
	while stack.size() > 0:
		var current = stack.back()
		var neighbors = _get_unvisited_neighbors(current.x, current.y)
		
		if neighbors.size() > 0:
			var next = neighbors[rng.randi() % neighbors.size()]
			_remove_wall(current.x, current.y, next.x, next.y)
			grid[next.x][next.y] |= VISITED
			stack.append(next)
		else:
			stack.pop_back()

# ============================
# ALGORITHM 2: PRIM'S / خوارزمية بريم
# ============================

func _prims_algorithm() -> void:
	## تنتج متاهات أكثر تفرعاً وتعقيداً
	var start_x = rng.randi() % width
	var start_y = rng.randi() % height
	grid[start_x][start_y] |= VISITED
	
	var walls := []  # قائمة الجدران المحيطة
	_add_walls_to_list(start_x, start_y, walls)
	
	while walls.size() > 0:
		var rand_idx = rng.randi() % walls.size()
		var wall = walls[rand_idx]
		walls.remove_at(rand_idx)
		
		var ax = wall[0]; var ay = wall[1]
		var bx = wall[2]; var by = wall[3]
		
		# إذا كانت الخلية B غير مزارة
		if _is_valid(bx, by) and not (grid[bx][by] & VISITED):
			_remove_wall(ax, ay, bx, by)
			grid[bx][by] |= VISITED
			_add_walls_to_list(bx, by, walls)

func _add_walls_to_list(x: int, y: int, walls: Array) -> void:
	for i in range(4):
		var nx = x + DIRECTIONS[i].x
		var ny = y + DIRECTIONS[i].y
		if _is_valid(nx, ny) and not (grid[nx][ny] & VISITED):
			walls.append([x, y, nx, ny])

# ============================
# ALGORITHM 3: ELLER'S / خوارزمية إيلر
# ============================

func _ellers_algorithm() -> void:
	## فعّالة للذاكرة وتنتج متاهات متوازنة
	var sets := []  # مجموعة لكل خلية في الصف
	var next_set := 1
	
	for x in range(width):
		sets.append(next_set)
		next_set += 1
	
	for y in range(height - 1):
		# الدمج الأفقي العشوائي
		for x in range(width - 1):
			if sets[x] != sets[x + 1] and rng.randf() > 0.5:
				var old_set = sets[x + 1]
				var new_set = sets[x]
				for i in range(width):
					if sets[i] == old_set:
						sets[i] = new_set
				_remove_wall(x, y, x + 1, y)
		
		# الاتصال العمودي (مجموعة واحدة على الأقل)
		var new_sets := []
		for x in range(width):
			new_sets.append(-1)
		
		var set_counts := {}
		for x in range(width):
			var s = sets[x]
			if not s in set_counts:
				set_counts[s] = []
			set_counts[s].append(x)
		
		for s in set_counts:
			var cells = set_counts[s]
			var connected_count = max(1, rng.randi() % cells.size())
			cells.shuffle()
			for i in range(cells.size()):
				if i < connected_count:
					_remove_wall(cells[i], y, cells[i], y + 1)
					new_sets[cells[i]] = sets[cells[i]]
				else:
					new_sets[cells[i]] = next_set
					next_set += 1
		
		sets = new_sets
	
	# الصف الأخير: دمج كل المجموعات المختلفة
	var y_last = height - 1
	for x in range(width - 1):
		if sets[x] != sets[x + 1]:
			var old_set = sets[x + 1]
			for i in range(width):
				if sets[i] == old_set:
					sets[i] = sets[x]
			_remove_wall(x, y_last, x + 1, y_last)

# ============================
# ALGORITHM 4: GROWING TREE / الشجرة المتنامية
# ============================

func _growing_tree() -> void:
	## متحكمة بنسبة التعقيد/البساطة
	var cells := []
	var start_x = rng.randi() % width
	var start_y = rng.randi() % height
	cells.append(Vector2i(start_x, start_y))
	grid[start_x][start_y] |= VISITED
	
	while cells.size() > 0:
		# مزيج بين آخر خلية (75%) وخلية عشوائية (25%) لمتاهة متوازنة
		var idx: int
		if rng.randf() < 0.75:
			idx = cells.size() - 1  # آخر خلية
		else:
			idx = rng.randi() % cells.size()  # عشوائي
		
		var current = cells[idx]
		var neighbors = _get_unvisited_neighbors(current.x, current.y)
		
		if neighbors.size() > 0:
			var next = neighbors[rng.randi() % neighbors.size()]
			_remove_wall(current.x, current.y, next.x, next.y)
			grid[next.x][next.y] |= VISITED
			cells.append(next)
		else:
			cells.remove_at(idx)

# ============================
# ALGORITHM 5: ALDOUS-BRODER + WILSON HYBRID / هجين الدران ويلسن
# ============================

func _aldous_broder_wilson() -> void:
	## تنتج متاهات غير منحازة (unbiased) - الأكثر تعقيداً وعشوائية
	var total_cells = width * height
	var visited_count := 1
	
	# مرحلة Aldous-Broder الأولى (حتى 40% من الخلايا)
	var cx = rng.randi() % width
	var cy = rng.randi() % height
	grid[cx][cy] |= VISITED
	
	var ab_limit = total_cells * 4 / 10  # 40%
	while visited_count < ab_limit:
		var dir = rng.randi() % 4
		var nx = cx + DIRECTIONS[dir].x
		var ny = cy + DIRECTIONS[dir].y
		if _is_valid(nx, ny):
			if not (grid[nx][ny] & VISITED):
				_remove_wall(cx, cy, nx, ny)
				grid[nx][ny] |= VISITED
				visited_count += 1
			cx = nx
			cy = ny
	
	# مرحلة Wilson's Algorithm (المسار العشوائي Loop-Erased)
	for sx in range(width):
		for sy in range(height):
			if grid[sx][sy] & VISITED:
				continue
			
			# مسار عشوائي حتى خلية مزارة
			var path := [Vector2i(sx, sy)]
			var path_set := {Vector2i(sx, sy): 0}
			var px = sx; var py = sy
			
			while not (grid[px][py] & VISITED):
				var dir = rng.randi() % 4
				var nx = px + DIRECTIONS[dir].x
				var ny = py + DIRECTIONS[dir].y
				if not _is_valid(nx, ny):
					continue
				
				var next_cell = Vector2i(nx, ny)
				if next_cell in path_set:
					# حذف الحلقة (Loop Erasure)
					var loop_start = path_set[next_cell]
					for i in range(path.size() - 1, loop_start, -1):
						path_set.erase(path[i])
					path = path.slice(0, loop_start + 1)
				else:
					path_set[next_cell] = path.size()
					path.append(next_cell)
				
				px = nx; py = ny
			
			# إضافة المسار للمتاهة
			for i in range(path.size() - 1):
				var a = path[i]; var b = path[i + 1]
				if not (grid[a.x][a.y] & VISITED):
					_remove_wall(a.x, a.y, b.x, b.y)
					grid[a.x][a.y] |= VISITED
					visited_count += 1

# ============================
# HELPER FUNCTIONS / الدوال المساعدة
# ============================

func _get_unvisited_neighbors(x: int, y: int) -> Array:
	var result := []
	for dir in DIRECTIONS:
		var nx = x + dir.x
		var ny = y + dir.y
		if _is_valid(nx, ny) and not (grid[nx][ny] & VISITED):
			result.append(Vector2i(nx, ny))
	return result

func _remove_wall(ax: int, ay: int, bx: int, by: int) -> void:
	## إزالة الجدار بين خليتين متجاورتين
	var dx = bx - ax
	var dy = by - ay
	
	if dx == 1:   # شرق
		grid[ax][ay] &= ~WALL_EAST
		grid[bx][by] &= ~WALL_WEST
	elif dx == -1:  # غرب
		grid[ax][ay] &= ~WALL_WEST
		grid[bx][by] &= ~WALL_EAST
	elif dy == 1:  # جنوب
		grid[ax][ay] &= ~WALL_SOUTH
		grid[bx][by] &= ~WALL_NORTH
	elif dy == -1:  # شمال
		grid[ax][ay] &= ~WALL_NORTH
		grid[bx][by] &= ~WALL_SOUTH

func _is_valid(x: int, y: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height

# ============================
# PATHFINDING (A*) / إيجاد المسار
# ============================

func find_shortest_path(start: Vector2i, goal: Vector2i) -> Array:
	## A* لإيجاد أقصر مسار (يستخدمه اللص)
	var open_set := {start: true}
	var came_from := {}
	var g_score := {start: 0}
	var f_score := {start: _heuristic(start, goal)}
	
	while open_set.size() > 0:
		# الحصول على الخلية ذات أدنى f_score
		var current: Vector2i
		var min_f = INF
		for cell in open_set:
			if f_score.get(cell, INF) < min_f:
				min_f = f_score[cell]
				current = cell
		
		if current == goal:
			return _reconstruct_path(came_from, current)
		
		open_set.erase(current)
		
		# فحص الجيران المتاحين (بدون جدار بينهم)
		for i in range(4):
			var wall = DIR_WALLS[i]
			if grid[current.x][current.y] & wall:
				continue  # يوجد جدار
			
			var neighbor = current + DIRECTIONS[i]
			if not _is_valid(neighbor.x, neighbor.y):
				continue
			
			var tentative_g = g_score.get(current, INF) + 1
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + _heuristic(neighbor, goal)
				open_set[neighbor] = true
	
	return []  # لا يوجد مسار

func _heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var path := [current]
	while current in came_from:
		current = came_from[current]
		path.push_front(current)
	return path

# ============================
# UTILITY / أدوات
# ============================

func get_cell_world_position(cell: Vector2i, cell_size: float = 4.0) -> Vector3:
	## تحويل إحداثيات الشبكة إلى إحداثيات ثلاثية الأبعاد
	return Vector3(cell.x * cell_size, 0.0, cell.y * cell_size)

func get_random_empty_cell() -> Vector2i:
	## الحصول على خلية فارغة عشوائية
	return Vector2i(rng.randi() % width, rng.randi() % height)

func is_walkable(x: int, y: int) -> bool:
	return _is_valid(x, y)
