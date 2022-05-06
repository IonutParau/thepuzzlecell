# Translation Help

This markdown file is to help people make their own translations. It explains what each field in the JSON actually is for.

## How do I get cell and button IDs?

Cell, Category and Subcategory IDs are revealed by enabling debug mode in the game's settings.
The button IDs can be found in the code, and this markdown file will also slow them

## Translation variables

In the text, @variablename gets replaced with the variable.

## Fields:

| Field format            | What it means for the language interpreter                                                                                              | Variables |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| cellid.title            | "The value of this field should be the title of the cell with ID cellid"                                                                |           |
| cellid.desc             | "The value of this field should be the description of the cell with ID cellid"                                                          |           |
| buttonid.title          | "The value of this field should be the title of the button with ID buttonid"                                                            |           |
| buttonid.desc           | "The value of this field should be the description of the button with ID buttonid"                                                      |           |
| categoryid.title        | "The value of this field should be the title of the category with ID categoryid"                                                        |           |
| categoryid.desc         | "The value of this field should be the description of the category with ID categoryid"                                                  |           |
| subcategoryid.title     | "The value of this field should be the title of the subcategory with ID subcategoryid"                                                  |           |
| subcategoryid.desc      | "The value of this field should be the description of the subcategory with ID subcategoryid"                                            |           |
| title                   | The title to show in the languages menu                                                                                                 |           |
| editor                  | The name of the editor screen                                                                                                           |           |
| puzzles                 | The name of the puzzles screen                                                                                                          |           |
| worlds                  | The name of the worlds screen                                                                                                           |           |
| puzzle                  | The name of the puzzle button                                                                                                           |           |
| delete                  | The name of the delete button                                                                                                           |           |
| multiplayer             | The name of the multiplayer screen                                                                                                      |           |
| settings                | The name of the settings screen                                                                                                         |           |
| languages               | The name of the language screen                                                                                                         |           |
| credits                 | The name of the credits screen                                                                                                          |           |
| version                 | The name of the version screen                                                                                                          |           |
| loadLevel               | The name of the load level button                                                                                                       |           |
| saveError               | The title of the Invalid Save error message                                                                                             |           |
| saveErrorDesc           | The description of the Invalid Save error message                                                                                       | error     |
| yes                     | For every confirmation prompt, this is what would get shown instead of Yes                                                              |           |
| no                      | For every confirmation prompt, this is what would get shown instead of No                                                               |           |
| world_del_title         | The title of the world delete confirmation prompt                                                                                       | world     |
| world_del_content       | The message to show in the confirmation prompt                                                                                          |           |
| add                     | The name of the add button in some pages                                                                                                |           |
| create_world            | The title of the Create a World page                                                                                                    |           |
| width                   | The name of the width box                                                                                                               |           |
| height                  | The name of the height box                                                                                                              |           |
| title_box               | The name of the title box in worlds                                                                                                     |           |
| description             | The name of the description box in worlds                                                                                               |           |
| play                    | The name of the play button                                                                                                             |           |
| connect                 | The name of the connect button in multiplayer                                                                                           |           |
| remove                  | The name of the delete button in multiplayer and worlds                                                                                 |           |
| ip_address              | The name of the IP / Address text box in Multiplayer                                                                                    |           |
| add_server              | Title of the Add Server page                                                                                                            |           |
| multiplayer_servers     | The title of the multiplayer servers that is different than `multiplayer` because it shows as the title of the page but not of the tile |           |
| update                  | The name of the update checker and of the Update button in the language downloader                                                      |           |
| versionError            | The text to show when an error occurs duing update checking                                                                             | error     |
| version_ok              | The text to show when the current version IS the most up-to-date                                                                        |           |
| version_out_of_date     | The text to show when the current version ISN'T the most up-to-date                                                                     |           |
| shop                    | The title of the in-game skin store                                                                                                     |           |
| quit                    | The name of the Quit button to close the app                                                                                            |           |
| update_delay            | The name of the Update Delay setting                                                                                                    |           |
| realistic_render        | The name of the Realistic Rendering setting                                                                                             |           |
| subticking              | The name of the Subticking setting                                                                                                      |           |
| titles_description      | The name of the Titles and Description setting                                                                                          |           |
| ui_scale                | The name of the UI Scale setting                                                                                                        |           |
| music_volume            | The name of the Music Volume setting                                                                                                    |           |
| debug_mode              | The name of the Debug Mode setting                                                                                                      |           |
| interpolation           | The name of the Interpolation setting                                                                                                   |           |
| cellbar                 | The name of the Cellbar setting                                                                                                         |           |
| exit                    | The name of the Exit button in the Editor Menu or title of the exit button                                                              |           |
| exit_desc               | The description of the Exit button in puzzle mode                                                                                       |           |
| clear                   | The name of the Clear button in the Editor Menu                                                                                         |           |
| wrapModeOn              | The title to show when Wrap Mode is enabled                                                                                             |           |
| wrapModeOff             | The title to show when Wrap Mode is disabled                                                                                            |           |
| lang_down               | The title of the language downloader page                                                                                               |           |
| install                 | For the word Install, commonly in the language downloader                                                                               |           |
| local_update            | The text of the dialog telling the user a translation has locally updated                                                               | name      |
| local_install           | Like local_update, but it shows it when the users installs it                                                                           | name      |
| local_update_content    | The content of the dialog for when the user updates a translation locally                                                               |           |
| local_install_content   | The content of the dialog for when the user installs a translation locally                                                              |
| locally_removed         | The title of the dialog for when the user locally deleted a translation                                                                 | name      |
| locally_removed_content | The content of the dialog for when the user locally deleted a translation                                                               |           |

## Button IDs:

- Back button - `back-btn`
- Load new puzzle - `m-load-btn`
- Save button - `save-btn`
- Load button - `load-btn`
- Wrap button - `wrap-btn`
- Rotate CW - `rot-cw-btn`
- Rotate CCW - `rot-ccw-btn`
- Select button - `select-btn`
- Copy button - `copy-btn`
- Cut button - `cut-btn`
- Delete button (for selections) - `del-btn`
- Paste button - `paste-btn`
- Play / Pause button - `play-btn`
- One Tick button - `onetick-btn`
- Restore button - `restore-btn`
- Set Initial button - `setinitial-btn`

## Example of JSON

Translations use the JSON markup language.
It is a markup language for describing objects with a syntax similar-ish to JavaScript's objects.

Simple example:

```json
{
  "field": "content"
}
```

Those curly brackets (aka `{` and `}`) are only at the start it to mark it as an object.

When typing multiple field-value pairs, add commas inbetween them.
Like so:

```json
{
  "field": "content",
  "other_field": "other content"
}
```

The last field-value pair must not have a , at the end or the parser fails and you get an error.

Hope this helped you!
