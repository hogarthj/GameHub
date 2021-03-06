/*
This file is part of GameHub.
Copyright (C) 2018-2019 Anatoliy Kashkin

GameHub is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GameHub is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GameHub.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gtk;
using Gdk;
using Gee;

using GameHub.Data;
using GameHub.Utils;
using GameHub.UI.Widgets;

namespace GameHub.UI.Views.GameDetailsView.Blocks
{
	public class Artwork: GameDetailsBlock
	{
		public Artwork(Game game)
		{
			Object(game: game, orientation: Orientation.VERTICAL, text_max_width: 48);
		}

		construct
		{
			var card = Styled.Card("gamecard", "static");

			var image_view = new AutoSizeImage();
			image_view.hexpand = false;
			image_view.set_constraint(360, 360, 0.467f);

			var actions = new Box(Orientation.VERTICAL, 0);
			actions.get_style_context().add_class("actions");
			actions.hexpand = true;
			actions.vexpand = false;

			var image_overlay = new Overlay();
			image_overlay.add(image_view);
			image_overlay.add_overlay(actions);

			var images_download_btn = new MenuButton();
			images_download_btn.get_style_context().add_class("images-download-button");
			images_download_btn.margin = 8;
			images_download_btn.halign = Align.END;
			images_download_btn.valign = Align.START;
			images_download_btn.image = new Image.from_icon_name("folder-download-symbolic", IconSize.BUTTON);
			images_download_btn.tooltip_text = _("Download images");

			image_overlay.add_overlay(images_download_btn);

			card.add(image_overlay);
			add(card);

			var images_download_popover = new ImagesDownloadPopover(game, images_download_btn);

			image_view.load(game.image, "image");
			game.notify["image"].connect(() => {
				image_view.load(game.image, "image");
			});

			show_all();
			if(parent != null) parent.queue_draw();
		}

		public override bool supports_game { get { return true; } }
	}
}
