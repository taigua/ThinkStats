### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# ╔═╡ af551046-78fc-4eeb-a181-b7bdcdefaf41
begin
	using DataFrames, DuckDB
	using PrettyTables, FreqTables
	using StatsBase
end

# ╔═╡ 4ece36ad-7e91-4813-9df6-9e52ffec50d1
include("utils.jl")

# ╔═╡ 7df534fb-c8d3-4713-b18c-320f65ec4402
preg = read_parquet("../data/2002FemPreg.parquet");

# ╔═╡ 74f771bf-ea3f-4304-b906-db1af157d8db
size(preg)

# ╔═╡ f13c4f8d-e6b4-4464-af61-36cdcb4e1cf8
first(preg, 5)

# ╔═╡ 968fe9b1-0563-4bf7-81f9-4eae4c7554a8
names(preg)

# ╔═╡ 71e71b1d-fe3d-4d5a-9416-52d5c34f74b5
begin
	pregordr = preg.pregordr
	typeof(pregordr)
end

# ╔═╡ bd3ac994-39fc-4373-af95-26d8bfe00f14
first(pregordr, 5)

# ╔═╡ c2d66bb3-b4e9-4077-b3b6-5f9024c75db8
DataFrame(	
    Value = [1, 2, 3, 4, 5, 6, "Total"],
    Label = [
        "LIVE BIRTH",
        "INDUCED ABORTION",
        "STILLBIRTH",
        "MISCARRIAGE",
        "ECTOPIC PREGNANCY",
        "CURRENT PREGNANCY",
        "",
    ],
    Total = [9148, 1862, 120, 1921, 190, 352, 13593],
)

# ╔═╡ d3b078d7-5371-4b45-a228-bec5a8468419
# freqtable is used in value_count
value_counts(preg, :outcome)

# ╔═╡ 5c0bac4e-ca00-42b0-aa2b-296cba497d8c
DataFrame(
    Values = [".", "0-5", "6", "7", "8", "9-95", "97", "98", "99", "Total"],
    Label = [
        "inapplicable",
        "UNDER 6 POUNDS",
        "6 POUNDS",
        "7 POUNDS",
        "8 POUNDS",
        "9 POUNDS OR MORE",
        "Not ascertained",
        "REFUSED",
        "DON'T KNOW",
        "",
    ],
    Total = [4449, 1125, 2223, 3049, 1889, 799, 1, 1, 57, 13593],
)

# ╔═╡ 5525e5d3-178f-4ab4-8f82-74aa0b3c26be
begin
	counts = freqtable(preg.birthwgt_lb)
	pretty_table(HTML, (birthwgt_lb=names(counts, 1), count=vec(counts)))
end


# ╔═╡ 94cfd5b6-bbad-4230-918d-f50f37e887bd
begin
	sub_counts = counts[0.0:5.0]
	pretty_table(HTML, (birthwgt_lb=names(sub_counts, 1), count=vec(sub_counts)))
end

# ╔═╡ 5f71700d-2411-45f8-a86c-4498c1567fb8
sum(sub_counts)

# ╔═╡ 46859437-75dc-467e-a253-21acb259d4c5
replace!(x -> !ismissing(x) && x ∈ [51, 97, 98, 99] ? missing : x, preg.birthwgt_lb);

# ╔═╡ 07de27eb-e76b-48fb-9322-3a261c69a31e
mean(skipmissing(preg.agepreg))

# ╔═╡ 35527bc3-7709-412b-ad83-7f3e474448a9
begin
	preg.agepreg ./= 100.0
	mean(skipmissing(preg.agepreg))
end

# ╔═╡ fb7731de-5e45-4970-af04-1924e8f7efec
value_counts(preg, :birthwgt_oz; skipmissing=false)

# ╔═╡ 5d860658-e2a3-4051-8050-8e72e6ca65dd
replace!(x -> !ismissing(x) && x ∈ [97, 98, 99] ? missing : x, preg.birthwgt_oz);

# ╔═╡ ac887072-255c-414d-8016-6622003596ad
begin
	preg.totalwgt_lb .= preg.birthwgt_lb .+ preg.birthwgt_oz ./ 16.0
    mean(skipmissing(preg.totalwgt_lb))
end

# ╔═╡ 32e7157a-55a2-44e5-8698-53976c1ed8ef
begin
	weights = preg.totalwgt_lb
	weights_n = count(!ismissing, weights)
end

# ╔═╡ 4fc1b649-2772-4791-ab9b-b0fa8a5167f6
weights_mean = sum(skipmissing(weights)) / weights_n

# ╔═╡ bbf95602-7ec8-48aa-b396-1a1f59345b31
mean(skipmissing(weights))

# ╔═╡ 77f6521f-cbb6-434a-8fca-bfb693908153
squared_deviations = (weights .- weights_mean) .^ 2;

# ╔═╡ 326e1b11-f75f-4ce3-a49d-37c799a4f4b8
weights_var = sum(skipmissing(squared_deviations)) / weights_n

# ╔═╡ 9372071f-7663-45c3-91e9-d6a2e3ead6a5
var(skipmissing(weights))

# ╔═╡ 636eabf3-eb35-4861-ae17-63277f596494
var(skipmissing(weights), corrected=false)

# ╔═╡ 87022048-e786-4758-9c04-5b4c9ffd6439
weights_std = sqrt(weights_var)

# ╔═╡ 90bbda04-e00c-4bc2-a7fa-34e9efedb13a
std(skipmissing(weights), corrected=false)

# ╔═╡ 44a55052-8605-4c8c-87f3-4afa104d2599
begin
	preg_subset = subset(preg, :caseid => ByRow(==(10229)))
	size(preg_subset)
end

# ╔═╡ 6e33233f-36ff-48ab-bd5c-729e5da36d1b
preg_subset.outcome

# ╔═╡ 16a3fe72-2abb-415e-a8a5-5c9781f1f90e
md"""
## Exercises

The exercises for this chapter are based on the NSFG pregnancy file.
"""

# ╔═╡ 6ca3a815-baf6-4853-902b-da8ccb6a19d9
md"""
### Exercise 1.1

Select the `birthord` column from `preg`, print the value counts, and compare to results published in the  codebook at <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NSFG/Cycle6Codebook-Pregnancy.pdf>.
"""

# ╔═╡ 6a21a338-989e-444a-90d2-56c8cc524e98
value_counts(preg, :birthord)

# ╔═╡ 05ec2ed8-9912-49c5-ad91-b0f73f8ad1a4
md"""
### Exercise 1.2

Create a new column named `totalwgt_kg` that contains birth weight in kilograms (there are approximately 2.2 pounds per kilogram).
Compute the mean and standard deviation of the new column.
"""

# ╔═╡ 2bc7d22d-b5f4-4059-9686-65c216129dba
begin
	preg.totalwgt_kg .= preg.totalwgt_lb ./ 2.2
	mean(skipmissing(preg.totalwgt_kg)), std(skipmissing(preg.totalwgt_kg))
end

# ╔═╡ 9ac73c81-37b2-4f54-9f5d-8bce24c9c52a
md"""
### Exercise 1.3

What are the pregnancy lengths for the respondent with `caseid` 2298?
"""

# ╔═╡ 76bb2ce1-230d-4c4e-ad76-d721f3751c6f
begin
	caseid_subset = subset(preg, :caseid => ByRow(==(2298)))
	caseid_subset.prglngth
end

# ╔═╡ a5e843db-1109-487a-9ba1-aeb787963d27
md"""
What was the birth weight of the first baby born to the respondent with `caseid` 5013?
Hint: You can use `and` to check more than one condition in a query.
"""

# ╔═╡ d8b78d8d-bcf9-4617-baa7-61804c74d20d
begin
	caseid_subset2 = subset(preg, :caseid => ByRow(==(5013)))
	caseid_subset2.totalwgt_lb
end

# ╔═╡ fa97a213-7f28-4664-9249-b745f4bc8496
begin
	caseid_subset3 = subset(preg, :caseid => ByRow(==(5013)), :birthord => ByRow(==(1)); skipmissing=true)
	caseid_subset3.totalwgt_lb
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
FreqTables = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
DataFrames = "~1.8.2"
DuckDB = "~1.5.2"
FreqTables = "~1.0.0"
PrettyTables = "~3.3.2"
StatsBase = "~0.34.10"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "7c7f2e8a364483e609ce07a50159339b3739416f"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitIntegers]]
deps = ["Random"]
git-tree-sha1 = "091d591a060e43df1dd35faab3ca284925c48e46"
uuid = "c3b6d118-76ef-56ca-8cc7-ebb389d030a1"
version = "0.3.7"

[[deps.CategoricalArrays]]
deps = ["Compat", "DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "a6f644eb7bbc0171286f0f3ad1ffde8f04be7b83"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "1.1.0"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysArrowExt = "Arrow"
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStatsBaseExt = "StatsBase"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    Arrow = "69666777-d1a9-59fb-9406-91d4454c9d45"
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Combinatorics]]
git-tree-sha1 = "c761b00e7755700f9cdf5b02039939d1359330e1"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.1.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "a444404b3f94deaa43ca2a58e18153a82695282b"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.6.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5fab31e2e01e70ad66e3e24c968c264d1cf166d6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.2"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e86f4a2805f7f19bec5129bc9150c38208e5dc23"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.4"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.DuckDB]]
deps = ["DBInterface", "Dates", "DuckDB_jll", "FixedPointDecimals", "Tables", "UUIDs", "WeakRefStrings"]
git-tree-sha1 = "656133510fa02a4f70a9d3ce6c1d083318406550"
uuid = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
version = "1.5.2"

[[deps.DuckDB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4f4bc0e8be87d6ab270a07caa182808958bff9fe"
uuid = "2cbbab25-fc8b-58cf-88d4-687a02676033"
version = "1.5.2+0"

[[deps.FixedPointDecimals]]
deps = ["BitIntegers", "Parsers"]
git-tree-sha1 = "41d3a5de0eab320cc04833a373f0fcb3640073d5"
uuid = "fb4d412d-6eee-574d-9565-ede6634db7b0"
version = "0.6.5"

[[deps.FreqTables]]
deps = ["CategoricalArrays", "Missings", "NamedArrays", "Tables"]
git-tree-sha1 = "a2f24a17652beedaac07ce78f4c985a52c76d005"
uuid = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
version = "1.0.0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "OrderedCollections", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "33d258318d9e049d26c02ca31b4843b2c851c0b0"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.10.5"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "5d5e0a78e971354b1c7bff0655d11fdc1b0e12c8"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.4"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "REPL", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "624de6279ab7d94fc9f672f0068107eb6619732c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "3.3.2"

    [deps.PrettyTables.extensions]
    PrettyTablesTypstryExt = "Typstry"

    [deps.PrettyTables.weakdeps]
    Typstry = "f0ed7684-a786-439e-b1e3-3b82803b501e"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ebe7e59b37c400f694f52b58c93d26201387da70"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.9"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "aceda6f4e598d331548e04cc6b2124a6148138e3"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.10"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "d05693d339e37d6ab134c5ab53c29fce5ee5d7d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.4"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "0716e01c3b40413de5dedbc9c5c69f27cddfddfc"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"
"""

# ╔═╡ Cell order:
# ╠═af551046-78fc-4eeb-a181-b7bdcdefaf41
# ╠═4ece36ad-7e91-4813-9df6-9e52ffec50d1
# ╠═7df534fb-c8d3-4713-b18c-320f65ec4402
# ╠═74f771bf-ea3f-4304-b906-db1af157d8db
# ╠═f13c4f8d-e6b4-4464-af61-36cdcb4e1cf8
# ╠═968fe9b1-0563-4bf7-81f9-4eae4c7554a8
# ╠═71e71b1d-fe3d-4d5a-9416-52d5c34f74b5
# ╠═bd3ac994-39fc-4373-af95-26d8bfe00f14
# ╠═c2d66bb3-b4e9-4077-b3b6-5f9024c75db8
# ╠═d3b078d7-5371-4b45-a228-bec5a8468419
# ╠═5c0bac4e-ca00-42b0-aa2b-296cba497d8c
# ╠═5525e5d3-178f-4ab4-8f82-74aa0b3c26be
# ╠═94cfd5b6-bbad-4230-918d-f50f37e887bd
# ╠═5f71700d-2411-45f8-a86c-4498c1567fb8
# ╠═46859437-75dc-467e-a253-21acb259d4c5
# ╠═07de27eb-e76b-48fb-9322-3a261c69a31e
# ╠═35527bc3-7709-412b-ad83-7f3e474448a9
# ╠═fb7731de-5e45-4970-af04-1924e8f7efec
# ╠═5d860658-e2a3-4051-8050-8e72e6ca65dd
# ╠═ac887072-255c-414d-8016-6622003596ad
# ╠═32e7157a-55a2-44e5-8698-53976c1ed8ef
# ╠═4fc1b649-2772-4791-ab9b-b0fa8a5167f6
# ╠═bbf95602-7ec8-48aa-b396-1a1f59345b31
# ╠═77f6521f-cbb6-434a-8fca-bfb693908153
# ╠═326e1b11-f75f-4ce3-a49d-37c799a4f4b8
# ╠═9372071f-7663-45c3-91e9-d6a2e3ead6a5
# ╠═636eabf3-eb35-4861-ae17-63277f596494
# ╠═87022048-e786-4758-9c04-5b4c9ffd6439
# ╠═90bbda04-e00c-4bc2-a7fa-34e9efedb13a
# ╠═44a55052-8605-4c8c-87f3-4afa104d2599
# ╠═6e33233f-36ff-48ab-bd5c-729e5da36d1b
# ╟─16a3fe72-2abb-415e-a8a5-5c9781f1f90e
# ╟─6ca3a815-baf6-4853-902b-da8ccb6a19d9
# ╠═6a21a338-989e-444a-90d2-56c8cc524e98
# ╟─05ec2ed8-9912-49c5-ad91-b0f73f8ad1a4
# ╠═2bc7d22d-b5f4-4059-9686-65c216129dba
# ╟─9ac73c81-37b2-4f54-9f5d-8bce24c9c52a
# ╠═76bb2ce1-230d-4c4e-ad76-d721f3751c6f
# ╟─a5e843db-1109-487a-9ba1-aeb787963d27
# ╠═d8b78d8d-bcf9-4617-baa7-61804c74d20d
# ╠═fa97a213-7f28-4664-9249-b745f4bc8496
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
