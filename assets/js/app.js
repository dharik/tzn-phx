// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import ClassicEditor from '@ckeditor/ckeditor5-build-classic'
import { h, render } from 'preact';
import MatchingApp from './matching';
import AdminMentorList from './admin/mentors';

if (document.getElementById('matching-app')) {
  render(<MatchingApp />, document.getElementById('matching-app'));
}

if (document.getElementById('admin-mentors')) {
  render(<AdminMentorList />, document.getElementById('admin-mentors'))
}

for (const element of document.getElementsByClassName('rte')) {
  ClassicEditor
    .create(element)
    .then(editor => {
      // console.log( "created editor", editor );
    })
    .catch(error => {
      // console.error( error );
    });
}
