import React from "react";

function Cell(props) {

  const fire_url = "https://icons.iconarchive.com/icons/google/noto-emoji-travel-places/256/42697-fire-icon.png";
  const brick_url = "https://opengameart.org/sites/default/files/styles/medium/public/BrickGrey_0.png";
  const burger_url = "https://opengameart.org/sites/default/files/styles/medium/public/burger_0.png";
  const white_url = "https://cocos2d-x.org/attachments/4564/Square.jpg";

  const pokerface_url = "https://hotemoji.com/images/dl/r/straight-face-emoji-by-google.png";
  const happy_url = "https://f0.pngfuel.com/png/630/1004/green-smiley-icon-png-clip-art.png"
  const angry_url = "https://cdn1.iconfinder.com/data/icons/smashicons-emoticons-cartoony-vol-3/46/174_-_Dead_emoticon_emoji_face-512.png";

  const images = [white_url, brick_url, burger_url, fire_url];
  let img = images[props.value];

  let val = "";
  let color = "black";
  if (props.isPos) {
    if (props.status == 0) {
      img = pokerface_url;
    } else if (props.status == 1) {
      img = angry_url;
    } else {
      img = happy_url;
    }
  }

  return (
    <img
      src={img}
      style= {{
        border: "1px solid grey",
        opacity: props.isPos ? 1 : 0.5,
        height: "32px",
        width: "32px",
        float: "left",
      }}
    />
  );
}

export class Grid extends React.Component {
  constructor(props) {
    super(props);
  }
  renderCell(id) {
    return (
      <Cell
        key={id}
        value = {this.props.grid && this.props.grid[id]}
        isPos = {this.props.position == id}
        status = {this.props.status}
      />
    )
  }
  renderRow(row) {
    return (
      <div className="row">
      <Cell
        value={1}
        isPos={false}
        status = {this.props.status}
      />
      {
        [...Array(16)].map((col, i) => this.renderCell(row * 16 + i))
      }
      <Cell
        value={1}
        isPos={false}
        status = {this.props.status}
      />
      </div>
    )
  }
  render() {
    return (
      <div className="container">
      <div className="row">
      {
        [...Array(18)].map((row, i) => <Cell value={1} isPos={false} status = {this.props.status}/>)
      }
      </div>
      {
        [...Array(16)].map((row, i) => this.renderRow(i))
      }
      <div className="row">
      {
        [...Array(18)].map((row, i) => <Cell value={1} isPos={false} status = {this.props.status}/>)
      }
      </div>
      </div>
    )
  }
}
