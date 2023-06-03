package hxml.ds;

class BuildFilesIter {
	var bf : BuildFiles;
	var i:Int;
	var keys : Array<String>;

	public function new(bf : BuildFiles) {
		this.bf = bf;
		this.i = 0;
		this.keys = [for (f in bf.lib.keys()) f ];
	}

	public function hasNext() {
		if (i < bf.project.length) return true;
		else if (i - bf.project.length < bf.core.length) return true;
		else {
			var offset = bf.project.length + bf.core.length;
			for (j in 0 ... keys.length) {
				if (i - offset < bf.lib[keys[j]].length) return true;
				offset += bf.lib[keys[j]].length;
			}
		}
		return false;
	}

	public function next() {
		var val : String;
		if (i < bf.project.length) {
			val = bf.project[i];
			i++;
			return val;
		} else if (i - bf.project.length < bf.core.length) {
			val = bf.core[i-bf.project.length];
			i++;
			return val;
		}	else {
			var offset = bf.project.length + bf.core.length;
			for (j in 0 ... keys.length) {
				if (i - offset < bf.lib.get(keys[j]).length) {
					val = bf.lib.get(keys[j])[i-offset];
					i ++;
					return val;
				}
				offset += bf.lib.get(keys[j]).length;
			}
		}
		throw('err');
	}
}
