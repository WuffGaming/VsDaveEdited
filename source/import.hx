import Paths;
#if sys
import sys.FileSystem;
import sys.io.File;
import polymod.fs.SysFileSystem;
#end
import haxe.Json;
import haxe.format.JsonParser;
import json.JSONData;
import json.patch.JSONPatch;
import modding.HAssets as Assets;

import options.Flags;

using StringTools;