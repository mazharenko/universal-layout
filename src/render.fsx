#r "nuget: Scriban, 5.10.0"
#r "nuget: FSharp.SystemCommandLine, 0.17.0-beta4"

open System.IO
open FSharp.SystemCommandLine

let run (layout : string, version : string, outDir : string option) = 
    let templatePath = Path.Combine(__SOURCE_DIRECTORY__, $"{layout}.klc.sbntxt")
    let template = Scriban.Template.Parse(File.ReadAllText(templatePath))
    let klc = template.Render({|version = version|})
    let out = outDir |> Option.defaultValue (Path.GetDirectoryName templatePath)
    File.WriteAllText(Path.Combine(out, $"{layout}.klc"), klc)

let layout = Input.Argument("layout")
let version = Input.OptionRequired<string>("--layout-version")
let outDir = Input.OptionMaybe<string>("--out-dir")

rootCommand fsi.CommandLineArgs[1..] {
    inputs (layout, version, outDir)
    setHandler run
}
