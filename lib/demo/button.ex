defmodule Demo.Button do

  @moduledoc"Contains demos."

  import Widget
  import Seagull

  #
  # BUTTON DEMO
  #

  @doc"Shows frame with different buttons."
  def start() do
    #define frame f
    f=frame :f, "This is frame", size: {700, 700}, position: {50, 50}, react: [:close, :mouse_left_down] do
      box :vertical do
        box :horizontal do
          button :A, label: "This button's label is\ntop aligned.", size: {170, 150}, label_align: :top
          button :B, label: "This button's label is\nbottom aligned.", size: {170, 150}, label_align: :bottom
          button :C, label: "This button's label is\nright aligned.", size: {170, 150}, label_align: :right
          button :D, label: "This button's label is\nleft aligned.", size: {170, 150}, label_align: :left
        end
        box :horizontal do
          button :E, label: "This button is\ndisabled.", disabled: true
          button :F, label: "This button is\ndefault.", default: true
          button :G, label: "This button\nfits exactly.", exact_fit: true
          button :M, label: "This button\nhas no border", no_border: true
        end
        box :horizontal do
          button :H, label: "This button\nreacts on clicks.", react: [:click]
          button :I, label: "This button reacts\non mouse down and up clicks.", react: [:mouse_left_down, :mouse_right_down,
            :mouse_middle_down, :mouse_left_up, :mouse_right_up, :mouse_middle_up]
          button :J, label: "This button reacts\non mouse entering\nand leaving it.", react: [:mouse_enter, :mouse_leave]
        end
        box :horizontal do
          button :K, label: "This button counts\nclicks: 0", react: [:click]
          button :L, label: "This button grows\nwhen you click it.", react: [:click]
        end
      end
    end

    #start new GUI process with frame f
    pid=WindowProcess.start f
    
    #react on messages from GUI process
    reaction pid

  end

  #reactions on messages from GUI process
  defp reaction(pid) do
    continue=true
    receive_event do
      from pid: ^pid do
        from widget: :f do
          :close->
            IO.puts "You closed frame."
            pid<-:destroy
            continue=false
          :mouse_left_down, {x, y}->
            IO.puts "You clicked on frame on position [#{x}, #{y}]."
        end
        from widget: :H, do: (:click->IO.puts "You clicked on button.")
        from widget: :I do
          :mouse_left_down, {x, y}->IO.puts "Your left mouse button is down on position [#{x}, #{y}]."
          :mouse_right_down, {x, y}->IO.puts "Your right mouse button is down on position [#{x}, #{y}]."
          :mouse_middle_down, {x, y}->IO.puts "Your middle mouse button is down on position [#{x}, #{y}]."
          :mouse_left_up, {x, y}->IO.puts "Your left mouse button is up on position [#{x}, #{y}]."
          :mouse_right_up, {x, y}->IO.puts "Your right mouse button is up on position [#{x}, #{y}]."
          :mouse_middle_up, {x, y}->IO.puts "Your middle mouse button is up on position [#{x}, #{y}]."
        end
        from widget: :J do
          :mouse_enter, {x, y}->IO.puts "Your mouse entered button on position [#{x}, #{y}]"
          :mouse_leave, {x, y}->IO.puts "Your mouse left button on position [#{x}, #{y}]"
        end
        from widget: :K do
          :click->
            label=get pid, :K, :label
            count=Regex.run(%r/[0-9]+/, label) |> Enum.first |> binary_to_integer
            count=count+1
            label=Regex.replace %r/([0-9]+)/, label, integer_to_binary(count)
            set pid, :K, :label, label
        end
        from widget: :L do
          :click->
            {w, h}=get pid, :L, :size
            set pid, :L, :size, {w+1, h+1}
        end
      end
    end
    if continue, do: reaction pid
  end

end
