import React from "react";
import { Grid } from "./Grid";

export class Game extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      currentLevel: undefined,
      solutionAddress: undefined,
      position: 0,
      status: 0,
    }
  }

  chooseLevel(levelId) {
    this.setState({
      currentLevel: levelId,
      position: this.props.startPositions[levelId],
      status: 0
    });
    this.props.onLevelChange();
  }

  handleChange(event) {
    this.setState({solutionAddress: event.target.value});
    event.preventDefault();
  }

  handleClick(ev) {
    this.setState({
      position: ev.args.x * 16 + ev.args.y,
      status: ev.args.state
    });
  }

  render() {
    return (
      <div className="container">

        <div className="row">
          Current level: {this.state.currentLevel} <br/>
          Number of levels: {this.props.levelsNum} <br/>
          Levels completed: {this.props.levelsCompleted} <br/>
        </div>

        <div className="row">
          <div className="col-md-7">
            <div className="row" style={{margin_bottom: "10px"}}>
              {
                [...Array(this.props.levelsNum)].map((x, i) =>
                  <button
                    type="button"
                    style={{width: "35px", margin: "1px"}}
                    className={i < this.props.levelsCompleted
                              ? "btn btn-success"
                              : i == this.props.levelsCompleted ? "btn btn-primary" : "btn btn-secondary"}
                    onClick={() => this.chooseLevel(i)}
                    disabled={i > this.props.levelsCompleted}>
                    {i}
                  </button>
                )
              }
            </div>

            <div className="row">
              {
                this.state.currentLevel >= 0
                ? <Grid position={this.state.position} status={this.state.status} grid={this.props.grids[this.state.currentLevel]}/>
                : <div className="alert alert-danger" role="alert">Please choose level above</div>
              }
            </div>
          </div>
          <div className="col-md-5">

            {this.state.currentLevel >= 0 && (<div>
              <div className="row">
                <form onSubmit={(event) => this.props.onSubmit(event, this.state.solutionAddress, this.state.currentLevel)}>
                  <label>
                    In order to complete a level, you have to write a Solution contract and submit its address below.
                    <br/>
                    Note that you have to be owner of Solution contract.
                    <br/>
                    <input type="text" value={this.state.solutionAddress} onChange={(event) => this.handleChange(event)} />
                  </label>
                  <br/>
                  <input type="submit" value="Run" />
                </form>
              </div>

              <hr/>

              {this.props.events && this.props.events.length > 0 && <div className="row">
                <ul class="list-group">
                  <button type="button" class="list-group-item list-group-item-action active">
                    Events log:
                  </button>
                  {this.props.events
                    .filter(ev => ev.event == "Left" || ev.event == "Right" || ev.event == "Up" || ev.event == "Down")
                    .map((ev, i) => (
                      <button type="button" key={i} class="list-group-item list-group-item-action" onClick={()=>this.handleClick(ev)}>
                          {i}: {ev.event}
                      </button>
                  ))}
                </ul>
              </div>}
            </div>)}
          </div>
        </div>

      </div>
    )
  }
}
