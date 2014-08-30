part of harmony;

typedef Future<String> GetText(String src);
typedef Future<ByteBuffer> GetBinary(String src);

/// Loads data from a webserver or a local filesystem
class Loader {
	final GetText _getText;
	final GetBinary _getBin;

	Loader(this._getText,this._getBin);




	Future<String> getText(String src) {
		return _getText(src);
	}
	Future<ByteBuffer> getBinary(String src) {
		return _getBin(src);
	}
}