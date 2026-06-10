using DataFrames
using DuckDB
using FreqTables
using PrettyTables

function read_parquet(filepath::AbstractString)::DataFrame    
    con = DBInterface.connect(DuckDB.DB, ":memory:")
    DataFrame(DBInterface.execute(con, "SELECT * FROM read_parquet('$filepath')"))
end

function value_counts(df::DataFrame, field::Symbol; skipmissing=false, normalize=false, ordered=false, rev=false, n=0)
    ft = freqtable(df[!, field], skipmissing=skipmissing)
    if normalize
        ft = prop(ft)
    end

    if ordered
        ft = sort(ft, rev=rev)
    end

    if n > 0
        ft = ft[1:n]
    end

    pretty_table(HTML, (field => names(ft, 1), count = vec(ft)))
end
