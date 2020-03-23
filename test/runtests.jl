using Test
using Pkg
using AutomotiveVisualization
using Colors
using Random
using AutomotiveDrivingModels

@testset "Renderable" begin
    rw = gen_straight_roadway(3, 100.0)
    car = ArrowCar(0.0, 0.0, 0.0, id=1)
    car2 = ArrowCar(1.0, 1.0, 1.0, color=colorant"green", text="text")

    render([rw, car, "some text"])
    render([rw, car, car2, "some text"], camera=TargetFollowCamera(0, zoom=10.))
    render([rw, car, car2, TextOverlay(text=["overlay"], color=colorant"blue")])
    c = render([rw, car, car2], camera=SceneFollowCamera(zoom=10.))
end

@testset "write SVG, PDF, PNG" begin 
    roadway = gen_stadium_roadway(4)
    c = render([roadway])
    write("out.svg", c)
    @test isfile("out.svg")

    # write pdf 
    camera = StaticCamera(position=(50,30), zoom=6.)
    c = render([roadway], camera=camera, 
           surface=AutomotiveVisualization.CairoPDFSurface(IOBuffer(), AutomotiveVisualization.canvas_width(camera), AutomotiveVisualization.canvas_height(camera)))
    write("out.pdf", c)

    # write png 
    c = render([roadway], camera=camera, 
           surface=AutomotiveVisualization.CairoRGBSurface(AutomotiveVisualization.canvas_width(camera), AutomotiveVisualization.canvas_height(camera)))
    write("out.png", c)

    # try to write svg surface to pdf 
    c = render([roadway], camera=camera)
    @test_throws ErrorException write("out.pdf", c)
    
    # try to write pdf surface to svg 
    c = render([roadway], camera=camera, 
           surface=AutomotiveVisualization.CairoPDFSurface(IOBuffer(), AutomotiveVisualization.canvas_width(camera), AutomotiveVisualization.canvas_height(camera)))
    @test_throws ErrorException write("out.svg", c)

    # png should always work 
    c = render([roadway], camera=camera)
    write("out2.png", c)
end

@testset "vehicle rendering" begin 
    AutomotiveVisualization.set_render_mode(:basic)
    @test AutomotiveVisualization.rendermode == :basic

    roadway = gen_stadium_roadway(4)
    vehstate = VehicleState(VecSE2(0.0, 0.0, 0.0), roadway, 0.0)

    def1 = VehicleDef()
    def2 = BicycleModel(def1)
    def3 = VehicleDef(AgentClass.PEDESTRIAN, 1.0, 1.0)

    veh1 = Entity(vehstate, def1, 1)
    veh2 = Entity(vehstate, def2, 2)
    veh3 = Entity(vehstate, def3, 3)

    render([roadway, veh1, veh2, veh3])

    AutomotiveVisualization.set_render_mode(:fancy)
    @test AutomotiveVisualization.rendermode == :fancy

    render([roadway, veh1, veh2, veh3])
    scene = Scene([veh1])
    cam = TargetFollowCamera(1)
    update_camera!(cam, scene)
    render([Scene([veh1, veh2, veh3])], camera = cam)  # TODO: multiple dispatch not working on update_camera!
    render([Scene([veh1, veh2, veh3])], camera=StaticCamera(zoom=10.))
end

@testset "color theme" begin
    AutomotiveVisualization.set_color_theme(OFFICETHEME)
    @test AutomotiveVisualization.colortheme == OFFICETHEME

    roadway = gen_stadium_roadway(4)
    vehstate = VehicleState(VecSE2(0.0, 0.0, 0.0), roadway, 0.0)

    def1 = VehicleDef()
    def2 = BicycleModel(def1)
    def3 = VehicleDef(AgentClass.PEDESTRIAN, 1.0, 1.0)

    veh1 = Entity(vehstate, def1, 1)
    veh2 = Entity(vehstate, def2, 2)
    veh3 = Entity(vehstate, def3, 3)

    render([roadway, veh1, veh2, veh3])

    AutomotiveVisualization.set_color_theme(LIGHTTHEME)
    @test AutomotiveVisualization.colortheme == LIGHTTHEME

    render([roadway, veh1, veh2, veh3])

    AutomotiveVisualization.set_color_theme(MONOKAY)
    @test AutomotiveVisualization.colortheme == MONOKAY

    s = Scene([veh1])
    d = get_pastel_car_colors(s)
    @test length(d) == length(s)
end

@testset "doc examples" begin
    @testset "basics" begin
        include("../docs/lit/tutorials/basics.jl")
    end
    @testset "cameras" begin
        include("../docs/lit/tutorials/cameras.jl")
    end
    @testset "overlays" begin
        include("../docs/lit/tutorials/overlays.jl")
    end
end
