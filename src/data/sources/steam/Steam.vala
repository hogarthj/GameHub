using Gtk;
using Gee;
using GameHub.Utils;

namespace GameHub.Data.Sources.Steam
{
	public class Steam: GameSource
	{
		private const string API_KEY = "8B10B604CAC6AC90F57AACE025DD904C";
		
		public override string name { get { return "Steam"; } }
		public override string icon { get { return "steam-symbolic"; } }
		public override string auth_description { owned get { return ".\n%s".printf(_("Your SteamID will be read from Steam configuration file")); } }
		
		public string? user_id { get; protected set; }
		public string? user_name { get; protected set; }

		private bool? installed = null;

		public override bool is_installed(bool refresh)
		{
			if(installed != null && !refresh)
			{
				return (!) installed;
			}
			
			installed = Utils.is_package_installed("steam");
			return (!) installed;
		}

		public override async bool install()
		{
			Utils.open_uri("appstream://steam.desktop");
			return true;
		}

		public override async bool authenticate()
		{
			if(is_authenticated()) return true;
			
			var result = false;
			
			new Thread<void*>("steam-loginusers-thread", () => {
				Json.Object config = Parser.parse_vdf_file(FSUtils.Paths.Steam.LoginUsersVDF);
				var users = config.get_object_member("users");
				
				foreach(var uid in users.get_members())
				{
					user_id = uid;
					user_name = users.get_object_member(uid).get_string_member("PersonaName");
					
					result = true;
					break;
				}
				
				Idle.add(authenticate.callback);
				return null;
			});
			
			yield;
			return result;
		}
		
		public override bool is_authenticated()
		{
			return user_id != null;
		}

		private ArrayList<Game> games = new ArrayList<Game>();
		public override async ArrayList<Game> load_games(FutureResult<Game>? game_loaded = null)
		{
			if(!is_authenticated() || games.size > 0)
			{
				return games;
			}
			
			var url = @"https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=$(Steam.API_KEY)&steamid=$(this.user_id)&format=json&include_appinfo=1";
			
			var root = yield Parser.parse_remote_json_file_async(url);
			var json_games = root.get_object_member("response").get_array_member("games");
			
			games.clear();
			
			foreach(var g in json_games.get_elements())
			{
				var game = new SteamGame(this, g.get_object());
				if(yield game.is_for_linux())
				{
					games.add(game);
					games_count = games.size;
					if(game_loaded != null) game_loaded(game);
				}
			}
			
			
			return games;
		}
	}
}