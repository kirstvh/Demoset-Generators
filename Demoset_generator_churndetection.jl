### A Pluto.jl notebook ###
# v0.19.15

#> [frontmatter]

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c832d1ea-758d-4d34-a217-9f01343898e2
using Distributions, PlutoUI, DataFrames, CSV

# ╔═╡ 7565213f-d145-4fde-ba11-f749123c8b09
begin
	using HypertextLiteral  
	ClickCounter(text="Click") = @htl("""
	<span>
	<button>$(text)</button>
	
	<script>
	
		// Select elements relative to `currentScript`
		const span = currentScript.parentElement
		const button = span.querySelector("button")
	
		// we wrapped the button in a `span` to hide its default behaviour from Pluto
	
		let count = 0
	
		button.addEventListener("click", (e) => {
			count += 1
	
			// we dispatch the input event on the span, not the button, because 
			// Pluto's `@bind` mechanism listens for events on the **first element** in the
			// HTML output. In our case, that's the span.
	
			span.value = count
			span.dispatchEvent(new CustomEvent("input"))
			e.preventDefault()
		})
	
		// Set the initial value
		span.value = count
	
	</script>
	</span>
	""")
end

# ╔═╡ 88e9e800-5fd0-4d84-8ef4-be5a0ffbc4f7
TableOfContents(title="📚 Table of Contents", indent=true, depth=10, aside=true)

# ╔═╡ ae18c030-6747-11ed-203e-8feab7e8aaff
md"# _Demoset Generator -  churn detection_

This notebook aims to automatically generate data for demos."

# ╔═╡ 4ef8ef32-da3c-4ba9-9907-61fe7f0eb0ac
md"## 📈 Define variables "

# ╔═╡ 674d72af-5fce-4c2e-84e1-0b78a4e938e8
md" ##### 🔽 Define variable names"

# ╔═╡ 0e6b9c91-822e-47cd-b342-9a08fc62a690
@bind vars_field confirm(TextField((50, 5), 
	"Omzet [miljoen EUR]\nTijd sinds laatste contact [dagen]\nAantal contactmomenten\nRegio\nSector"))

# ╔═╡ a7d82311-50e1-43f5-9a6c-dc7ec7d3fcc9
variables = [string(split(vars_field, "\n")[i]) for i in 1:length(split(vars_field, "\n"))]

# ╔═╡ 93e228ae-e55f-442e-aed7-311427a6b879
number_of_variables = length(variables)

# ╔═╡ cc05179a-bdcf-4408-b8af-43b7646761b4
md" ##### 🔽 Define label"

# ╔═╡ ad25661f-2213-4083-9f97-da2cf0d49ef6
label = "Uitval"

# ╔═╡ 2b0ffcae-3730-40c8-ae6b-980dedfaf1e7
md"##### 🔽 Choose variable distributions"

# ╔═╡ 9f2f37e4-dce9-45ab-b5d4-fae06dd576f8
md"##### 🔽 Choose distribution parameters"

# ╔═╡ 6468f2fc-feb1-4d22-bb2b-7cf3fcc5f716
md"##### 🔽 Choose function to calculate label"

# ╔═╡ cb9e4310-dba8-4720-bcee-bee0bbdb394f
function churn(features::DataFrame, n_samples) 
	threshhold = 1.3*mean(features[:,2])
	churn = Array{String}(undef, n_samples)
	for i in 1:n_samples
		som = features[i,2]  + randn() 
		if som > threshhold
			churn[i] = "JA"
		else
			churn[i] = "NEE"
		end
	end
	return churn
end

# ╔═╡ 1ffebffc-fb30-45f8-8392-4fd164e2179c
md"## 📄 Generate training data"

# ╔═╡ 9f7fb700-18be-4ad2-940c-32ae3ff79983
md"► Number of samples: $(@bind n_samples_train NumberField(5:5000, 100))"

# ╔═╡ cefc97cc-281e-4000-97f1-810e48a411b3
md"## 📄 Generate inference data"

# ╔═╡ 1aec6f49-bf80-403b-9a3a-32466109b767
md"► Number of samples: $(@bind n_samples_inference NumberField(5:5000, 10))"

# ╔═╡ 2cddbfc2-a55b-43ab-9cc5-0b8a7c5ee16d
md"##### 🔽 Download datasets"

# ╔═╡ 02a90be0-14c1-4046-a3a5-556c27ad9480
@bind names_demosets confirm(PlutoUI.combine() do Child
	md"""
► Name training demoset: $(Child(TextField((30, 1)))) $br 
► Name inference demoset: $(Child(TextField((30, 1))))  """
end)

# ╔═╡ c20391e2-3a52-422f-ab67-b0fe54532ec5
md"""►  $(@bind num_clicks ClickCounter("DOWNLOAD"))"""

# ╔═╡ 352dc52b-ab3e-4056-9fe7-a866c87b1e73
(training_name, inference_name) = names_demosets;

# ╔═╡ 36ab10dc-660e-4448-b01d-3a1841c566e2
md"## Functions"

# ╔═╡ e64be74a-56e1-4cd7-9c39-359b30070671
begin
	import PlutoUI: combine
	
	function choose_distribution_types(variables::Vector)		
		return combine() do Child	
			distributions = [
				md""" ► $(name): $(
					Child(name, Select([Normal() => "Normal", Poisson() => "Poisson", Exponential() => "Exponential",  Categorical([0.5, 0.5]) => "Categorical"]))
				) $br"""
				
				for name in variables
			]			
			md"""
			$(distributions)
			"""
		end
	end
end

# ╔═╡ 0daf09d1-fd31-4d7c-8c13-36de80cca65c
@bind distributions_types choose_distribution_types(variables)


# ╔═╡ af17c8d7-9faa-497a-b635-a3e687e7b30b
function choose_parameters(distribution, variable)
	
	return combine() do Child

		if distribution == Normal()
			params_distribution = "("*string(variable)*")"*"_".*["gemiddelde", "standardafwijking", "minimum", "maximum"]
		end

		if distribution == Poisson()
			params_distribution = "("*string(variable)*")"*"_".*["lambda", "minimum", "maximum"]
		end

		if distribution == Exponential()
			params_distribution = "("*string(variable)*")"*"_".*["lambda", "minimum", "maximum"]
		end

		if distribution == Categorical([0.5, 0.5])
			
			params = [
				md"""  🔹    **categories**_($variable)_: $(
					Child(string(variable,"_Categories"),TextField((30, 4), "A\nB")
)
				)""", 				md"""  🔹  **probabilities**_($variable)_: $(
					Child(string(variable, "_Probabilities"),TextField((30, 4), "0.5 \n0.5")
)
				)""" ]


		elseif distribution == Poisson()
			params = [
				md"""  🔹    **lambda**_($variable)_: $(
					Child("lambda",NumberField(0:100, default=10))
				)""", 
				md"""  🔹    **min**_($variable)_: $(
					Child("minimum",NumberField(0:100, default=0))
				)""", 
				md"""  🔹    **max**_($variable)_: $(
					Child("maximum",NumberField(0:100, default=100))
				)"""
				
				 
			]


		elseif distribution == Exponential()
			params = [
				md"""  🔹    **lambda**_($variable)_: $(
					Child("lambda",NumberField(0:100, default=10))
				)""", 
				md"""  🔹    **min**_($variable)_: $(
					Child("minimum",NumberField(0:100, default=0))
				)""", 
				md"""  🔹    **max**_($variable)_: $(
					Child("maximum",NumberField(0:100, default=100))
				)"""
				
				 
			]
		else  #distribution == Normal()
 			params = [
				md"""  🔹    **mean**_($variable)_: $(
					Child("mean",NumberField(0:100, default=1))
				)""", 
				md"""  🔹    **stdev**_($variable)_: $(
					Child("stdev",NumberField(0:100, default=2))
				)""", 
				md"""  🔹    **min**_($variable)_: $(
					Child("minimum",NumberField(0:100, default=0))
				)"""

				, 
				md"""  🔹    **max**_($variable)_: $(
					Child("maximum",NumberField(0:100, default=100))
				)"""
				
				 
			]
		end
				
		md"""
  		$(params) 
		"""
	end
end

# ╔═╡ a5367615-77cc-4f7a-9acb-ac0e896bcf8c
@bind params_1 choose_parameters(distributions_types[1], variables[1])


# ╔═╡ 234685c6-0c30-4284-971c-9bc01bebe1c6
@bind params_2 choose_parameters(distributions_types[2], variables[2]) 

# ╔═╡ 38a91554-df17-44a3-9c33-2a0fa6111bed
@bind params_3 choose_parameters(distributions_types[3], variables[3])

# ╔═╡ 92f717b9-49a2-456d-a733-bc476d9f94e5
if number_of_variables > 3
	@bind params_4 choose_parameters(distributions_types[4], variables[4])
else
	params_4 = nothing
end

# ╔═╡ d799fd5a-53cf-4d87-a447-f868c51bc6a4
if number_of_variables > 4
	@bind params_5 choose_parameters(distributions_types[5], variables[5])
else 
	params_5 = nothing
end

# ╔═╡ edd4489d-b1e6-4536-944d-c3179b83b21b
if number_of_variables > 5
	@bind params_6 choose_parameters(distributions_types[6], variables[6])
else
	params_6 = nothing
end

# ╔═╡ 4da6bb13-f7bc-40d1-b2bc-a7771555da42
function compose_distribution(params, distribution_type)
 	if distribution_type == Normal()
		distribution = Truncated(Normal(params[1], params[2]), 
			params[3], params[4])
	end

	 if distribution_type == Poisson()
		distribution = Truncated(Poisson(params[1]), 
			params[2], params[3])
	end

	 if distribution_type == Exponential()
		distribution = Truncated(Exponential(params[1]), 
			params[2], params[3])
	end

	if distribution_type == Categorical([0.5, 0.5])
		n_categories = length(split(params[1], "\n"))
		probability_vector = [parse(Float64, split(params[2], "\n")[i]) for i in 1:length(split(params[2], "\n"))]
		distribution = Categorical(probability_vector)
	end
	return distribution
end

# ╔═╡ a3afe007-fb04-4120-9ce5-f8fe70dad0f6
begin
	params = [params_1, params_2, params_3, params_4, params_5, params_6]
	distribution_1 = compose_distribution(params[1], distributions_types[1]);
	distribution_2 = compose_distribution(params[2], distributions_types[2]);
	distribution_3 = compose_distribution(params[3], distributions_types[3]);
	if number_of_variables > 3
		distribution_4 = compose_distribution(params[4], distributions_types[4]);
	end
	
	if number_of_variables > 4
		distribution_5 = compose_distribution(params[5], distributions_types[5]);
	else
		distribution_5 = nothing
	end
	
	if number_of_variables > 5
		distribution_6 = compose_distribution(params[6], distributions_types[6]);
	else
		distribution_6 = nothing
	end
	distributions = [distribution_1, distribution_2, distribution_3, distribution_4, distribution_5, distribution_6]
 end;

# ╔═╡ 8d0a81d5-96c8-4c09-8b58-6a8f4366d34a
begin
	df_train = DataFrame()
	for i in 1:number_of_variables
		sample_numerical = rand(distributions[i], n_samples_train)
		if typeof(distributions_types[i]) == Categorical{Float64, Vector{Float64}}
			categories = split(params[i][1], "\n")
			sample_categories = [categories[i] for i in sample_numerical]
			sample = sample_categories
		else 
			sample = sample_numerical
		end
		df_train[!, "Variable_"*string(i)] = sample
	end
	churn_sample = churn(df_train, n_samples_train)
	rename!(df_train, variables)
	df_train[!, string(label)] = churn_sample
	df_train
end

# ╔═╡ 303a7447-501f-4ea7-8594-d29cd8a18dac
begin
	df_inference = DataFrame()
	for i in 1:number_of_variables
		sample_numerical = rand(distributions[i], n_samples_inference)
		if typeof(distributions_types[i]) == Categorical{Float64, Vector{Float64}}
			categories = split(params[i][1], "\n")
			sample_categories = [categories[i] for i in sample_numerical]
			sample = sample_categories
		else 
			sample = sample_numerical
		end
		df_inference[!, "Variable_"*string(i)] = sample
	end
 	rename!(df_inference, variables)
 	df_inference
end

# ╔═╡ 340f6c2d-f314-407c-aa6e-bca1d9a4cd61
begin
	if num_clicks > 0
		CSV.write(string(training_name, ".csv"), df_train, delim=';');
		CSV.write(string(inference_name, ".csv"), df_inference, delim=';');
 	end;
end;

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.8"
DataFrames = "~1.4.4"
Distributions = "~0.25.79"
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "34be7b40efc898d7576835ed214fcc6cf0027f3f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "SnoopPrecompile", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "8c73e96bd6817c2597cfd5615b91fca5deccf1af"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.8"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d4f69885afa5e6149d0cab3818491565cf41446d"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "a7756d098cbabec6b3ac44f369f74915e8cfd70a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.79"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "9a0472ec2f5409db243160a8b030f94c380167a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "0cf92ec945125946352f3d46c96976ab972bde6f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "ab6083f09b3e617e34a956b43e9d51b824206932"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.1.1"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "e4bdc63f5c6d62e80eb1c0043fcc0360d5950ff7"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.10"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─88e9e800-5fd0-4d84-8ef4-be5a0ffbc4f7
# ╟─ae18c030-6747-11ed-203e-8feab7e8aaff
# ╠═c832d1ea-758d-4d34-a217-9f01343898e2
# ╟─4ef8ef32-da3c-4ba9-9907-61fe7f0eb0ac
# ╟─674d72af-5fce-4c2e-84e1-0b78a4e938e8
# ╟─0e6b9c91-822e-47cd-b342-9a08fc62a690
# ╟─a7d82311-50e1-43f5-9a6c-dc7ec7d3fcc9
# ╟─93e228ae-e55f-442e-aed7-311427a6b879
# ╟─cc05179a-bdcf-4408-b8af-43b7646761b4
# ╠═ad25661f-2213-4083-9f97-da2cf0d49ef6
# ╟─2b0ffcae-3730-40c8-ae6b-980dedfaf1e7
# ╟─0daf09d1-fd31-4d7c-8c13-36de80cca65c
# ╟─a3afe007-fb04-4120-9ce5-f8fe70dad0f6
# ╟─9f2f37e4-dce9-45ab-b5d4-fae06dd576f8
# ╟─a5367615-77cc-4f7a-9acb-ac0e896bcf8c
# ╟─234685c6-0c30-4284-971c-9bc01bebe1c6
# ╟─38a91554-df17-44a3-9c33-2a0fa6111bed
# ╟─92f717b9-49a2-456d-a733-bc476d9f94e5
# ╟─d799fd5a-53cf-4d87-a447-f868c51bc6a4
# ╟─edd4489d-b1e6-4536-944d-c3179b83b21b
# ╟─6468f2fc-feb1-4d22-bb2b-7cf3fcc5f716
# ╠═cb9e4310-dba8-4720-bcee-bee0bbdb394f
# ╟─1ffebffc-fb30-45f8-8392-4fd164e2179c
# ╟─9f7fb700-18be-4ad2-940c-32ae3ff79983
# ╟─8d0a81d5-96c8-4c09-8b58-6a8f4366d34a
# ╟─cefc97cc-281e-4000-97f1-810e48a411b3
# ╟─1aec6f49-bf80-403b-9a3a-32466109b767
# ╟─303a7447-501f-4ea7-8594-d29cd8a18dac
# ╟─2cddbfc2-a55b-43ab-9cc5-0b8a7c5ee16d
# ╟─02a90be0-14c1-4046-a3a5-556c27ad9480
# ╟─c20391e2-3a52-422f-ab67-b0fe54532ec5
# ╟─352dc52b-ab3e-4056-9fe7-a866c87b1e73
# ╟─340f6c2d-f314-407c-aa6e-bca1d9a4cd61
# ╟─36ab10dc-660e-4448-b01d-3a1841c566e2
# ╟─e64be74a-56e1-4cd7-9c39-359b30070671
# ╟─af17c8d7-9faa-497a-b635-a3e687e7b30b
# ╟─4da6bb13-f7bc-40d1-b2bc-a7771555da42
# ╟─7565213f-d145-4fde-ba11-f749123c8b09
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
