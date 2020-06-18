"""
    read_circ(file_input)

Takes circ file with name `file_input` and returns arrays 
of radii, x, and y coordinates.
"""
function read_circ(file_input::String)
    # read in circ file
    circfile = string(file_input)
    f         = open(circfile,"r")
    lines     = readlines(f)
    num_lines = length(lines)
    close(f)

    # obtain pre-processing parameters (# bodies, radii, x/y centers)
    nbodies = parse(Int,lines[2])
    radiusArr = zeros(nbodies)
    xArr = zeros(nbodies)
    yArr = zeros(nbodies)

    tind = 1
    for ti = 4:3:num_lines-1
        radiusArr[tind] = parse(Float64,lines[ti])
        xArr[tind] = parse(Float64,lines[ti+1])
        yArr[tind] = parse(Float64,lines[ti+2])
        tind += 1
    end
    return radiusArr, xArr, yArr
end

"""
    write_circ(file_name,radiusArr,xArr,yArr)

Writes `circ` file (text file) with name `file_name`, using arrays 
for radius, x and y positions
"""
function write_circ(file_name::String,radiusArr,xArr,yArr)
    filepath = string(file_name)
    open(filepath, "w") do io
        println(io, "# nbods")
        println(io, ps.param.n_objects)
        println(io, "# data below: radius, xc, yc for each body.")
        for ti=1:ps.param.n_objects
            println(io, radiusArr[ti])
            println(io, xArr[ti])
            println(io, yArr[ti])
        end
    end
    nothing
end
"""
    write_circ(file_name,ps)

Takes vector of particles `pList` and writes `circ` file 
(text file) with name `file_name`
"""
function write_circ(file_name::String,pList)
    filepath = string(file_name)
    open(filepath, "w") do io
        println(io, "# nbods")
        println(io, ps.param.n_objects)
        println(io, "# data below: radius, xc, yc for each body.")
        for ti=1:ps.param.n_objects
            println(io, pList[ti].radius)
            println(io, pList[ti].pos.x)
            println(io, pList[ti].pos.y)
        end
    end
    nothing
end

"""
    read_in_circ2(file_name)
"""
function read_circ2(file_name::String)
    f         = open(file_name,"r")
    lines     = readlines(f)
    num_lines = length(lines)
    close(f)

    # obtain pre-processing parameters (# bodies, radii, x/y centers, materialID)
    nbodies   = parse(Int,lines[2])
    radiusArr = zeros(nbodies)
    xArr      = zeros(nbodies)
    yArr      = zeros(nbodies)
    matID     = zeros(Int,nbodies)

    tind = 1
    for ti = 4:4:num_lines-1
        radiusArr[tind] = parse(Float64,lines[ti])
        xArr[tind] = parse(Float64,lines[ti+1])
        yArr[tind] = parse(Float64,lines[ti+2])
        matID[tind] = parse(Int,lines[ti+3])
        tind += 1
    end

    return radiusArr, xArr, yArr, matID
end
""" 
    write_circ2(file_name,pList)
"""
function write_circ2(file_name,radiusArr,xArr,yArr,matIDArr)
    filepath = string(file_name)
    open(filepath, "w") do io
        println(io, "# nbods")
        println(io, length(radiusArr))
        println(io, "# data below: radius, xc, yc, materialID for each body.")
        for ti=1:length(radiusArr)
            println(io, radiusArr[ti])
            println(io, xArr[ti])
            println(io, yArr[ti])
            println(io, matIDArr[ti])
        end
    end
end
function write_circ2(file_name,pList)
    filepath = string(file_name)
    open(filepath, "w") do io
        println(io, "# nbods")
        println(io, length(pList))
        println(io, "# data below: radius, xc, yc, materialID for each body.")
        for ti=1:length(pList)
            println(io, pList[ti].radius)
            println(io, pList[ti].pos.x)
            println(io, pList[ti].pos.y)
            println(io, pList[ti].materialID)
        end
    end
end

"""
    read_wall(file_name)
"""
function read_wall(file_name)
    f         = open(file_name,"r")
    lines     = readlines(f)
    num_lines = length(lines)
    close(f)

    nwalls  = parse(Int,lines[2])
    wList   = Array{AbstractWall}(undef,nwalls)

    tind = 1
    for ti = 4:8:num_lines-1
        linetype = lines[ti]
        x0 = parse(Float64,lines[ti+1])
        y0 = parse(Float64,lines[ti+2])
        if linetype == ":Line"
            x1 = parse(Float64,lines[ti+3])
            y1 = parse(Float64,lines[ti+4])
            thickness = parse(Float64,lines[ti+5])
            wList[tind] = LineWall(Point2D(x0,y0),Point2D(x1,y1),thickness)
        elseif linetype == ":Circle"
            radius = parse(Float64,lines[ti+3])
            thickness = parse(Float64,lines[ti+4])
            wList[tind] = CircleWall(Point2D(x0,y0),radius,thickness)
        elseif linetype == ":Arc"
            x1 = parse(Float64,lines[ti+3])
            y1 = parse(Float64,lines[ti+4])
            x2 = parse(Float64,lines[ti+5])
            y2 = parse(Float64,lines[ti+6])
            thickness = parse(Float64,lines[ti+7])
            wList[tind] = ArcWall(Point2D(x0,y0),Point2D(x1,y1),Point2D(x2,y2),thickness)
        else
            error("Linetype $(linetype) not recognized.")
        end
        tind +=1
    end
    return wList
end

"""
    write_wall(file_name,wList)
"""
function write_wall(file_name,wList)
    n_walls = length(wList)

    filepath = string(file_name)
    open(filepath, "w") do io
        println(io, "# walls")
        println(io, n_walls)
        println(io, "# data below: depends on linetype.")
        for ti=1:n_walls
            # print wall type
            if typeof(wList[ti]) <: LineWall
                println(io,":Line")
                println(io,wList[ti].nodes[1].x)
                println(io,wList[ti].nodes[1].y)
                println(io,wList[ti].nodes[2].x)
                println(io,wList[ti].nodes[2].y)
                println(io,wList[ti].thickness)
                println(io,"n/a")
                println(io,"n/a")
            elseif typeof(wList[ti]) <: CircleWall
                println(io,":Circle")
                println(io,wList[ti].center.x)
                println(io,wList[ti].center.y)
                println(io,wList[ti].radius)
                println(io,wList[ti].thickness)
                println(io,"n/a")
                println(io,"n/a")
                println(io,"n/a")
            elseif typeof(wList[ti]) <: ArcWall
                println(io,":Arc")
                println(io,wList[ti].nodes[1].x)
                println(io,wList[ti].nodes[1].y)
                println(io,wList[ti].nodes[2].x)
                println(io,wList[ti].nodes[2].y)
                println(io,wList[ti].nodes[3].x)
                println(io,wList[ti].nodes[3].y)
                println(io,wList[ti].thickness)
            end
        end
    end
end

"""
    combine_circ(output_name,input_files...)

Combines circ and circ2 files into one large circ (or circ2) file named
"output_name". If any of the input files are circ2, then all circ files 
are converted to circ2 with materialID equal to zero.
"""
function combine_circ(output_name,input_files...)
    n_files = length(input_files)
    n_particles = 0

    # check if any extensions are circ2
    circ2_bool_arr = Array{Bool}(undef,n_files)
    for ti=1:n_files
        circ2_bool_arr[ti] = is_circ2_extension(input_files[ti])
    end
    any_circ2_bool = any(circ2_bool_arr)

    # get number of total points with 1st pass through
    for ti=1:n_files
        if !circ2_bool_arr[ti]
            tempradArr, _, _ = read_circ(input_files[ti])
        elseif circ2_bool_arr[ti]
            tempradArr, _, _, _ = read_circ2(input_files[ti])
        end
        n_particles += length(tempradArr)
    end

    # initialize full arrays
    radiusArr = zeros(n_particles)
    xArr      = zeros(n_particles)
    yArr      = zeros(n_particles)
    matIDArr  = zeros(n_particles)

    # fill in arrays with 2nd pass through
    tk = 1
    for ti=1:n_files
        if !(circ2_bool_arr[ti])
            tempradArr, tempxArr, tempyArr = read_circ(input_files[ti])
        elseif circ2_bool_arr[ti]
            tempradArr, tempxArr, tempyArr, tempMatIDArr = read_circ2(input_files[ti])
        end
        n_particles = length(radArr)
        for tj=1:n_particles
            radiusArr[tk] = tempradArr[tj]
            xArr[tk] = tempxArr[tj]
            yArr[tk] = tempyArr[tj]
            if circ2_bool_arr[ti]
                matIDArr[tk] = tempMatIDArr[ti]
            end
            tk += 1
        end
    end

    if any_circ2_bool
        write_circ2(output_name,radiusArr,xArr,yArr,matIDArr)
    else
        write_circ(output_name,radiusArr,xArr,yArr)
    end

    nothing
end

function is_circ_extension(filename::String)
    _,ext = splitext(filename)
    return (ext == ".circ" ? true : false) 
end

function is_circ2_extension(filename::String)
    _,ext = splitext(filename)
    return (ext == ".circ2" ? true : false) 
end